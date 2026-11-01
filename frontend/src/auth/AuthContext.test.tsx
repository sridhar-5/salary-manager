import { screen, render } from "@testing-library/react";
import { AUTH_TOKEN_KEY } from "../api/client";
import { emptyResponse, jsonResponse } from "../test/http";
import { AuthProvider, isApiError, useAuth } from "./AuthContext";
import { ApiError } from "../api/client";

const admin = { id: 1, email: "hr@example.com", roles: ["compensation_admin"] };

function Probe() {
  const auth = useAuth();
  return (
    <div>
      <div data-testid="loading">{String(auth.loading)}</div>
      <div data-testid="email">{auth.admin?.email ?? "none"}</div>
      <button type="button" onClick={() => void auth.login("hr@example.com", "password").catch(() => undefined)}>
        Log in
      </button>
      <button type="button" onClick={() => void auth.logout()}>
        Log out
      </button>
    </div>
  );
}

function renderAuth() {
  return render(
    <AuthProvider>
      <Probe />
    </AuthProvider>,
  );
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn());
});

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("AuthProvider", () => {
  it("starts signed out when there is no stored token", () => {
    renderAuth();

    expect(screen.getByTestId("loading")).toHaveTextContent("false");
    expect(screen.getByTestId("email")).toHaveTextContent("none");
    expect(fetch).not.toHaveBeenCalled();
  });

  it("restores the signed-in admin from the stored token", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ admin_user: admin }));

    renderAuth();

    expect(screen.getByTestId("loading")).toHaveTextContent("true");
    expect(await screen.findByTestId("email")).toHaveTextContent("hr@example.com");
    expect(screen.getByTestId("loading")).toHaveTextContent("false");
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBe("secret");
  });

  it("drops an expired token when the session cannot be restored", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "Session expired" }, 401));

    renderAuth();

    expect(await screen.findByTestId("email")).toHaveTextContent("none");
    expect(screen.getByTestId("loading")).toHaveTextContent("false");
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
  });

  it("stores the token returned by login", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ token: "new-token", admin_user: admin }));
    renderAuth();

    screen.getByRole("button", { name: "Log in" }).click();

    expect(await screen.findByTestId("email")).toHaveTextContent("hr@example.com");
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBe("new-token");
  });

  it("does not store a token when login fails", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "Invalid email or password" }, 401));
    renderAuth();

    screen.getByRole("button", { name: "Log in" }).click();

    await vi.waitFor(() => expect(fetch).toHaveBeenCalled());
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
    expect(screen.getByTestId("email")).toHaveTextContent("none");
  });

  it("clears the session on logout even when the request fails", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch)
      .mockResolvedValueOnce(jsonResponse({ admin_user: admin }))
      .mockRejectedValueOnce(new Error("offline"));
    renderAuth();
    expect(await screen.findByTestId("email")).toHaveTextContent("hr@example.com");

    screen.getByRole("button", { name: "Log out" }).click();

    expect(await screen.findByTestId("email")).toHaveTextContent("none");
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
  });

  it("clears the admin after a successful logout", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch)
      .mockResolvedValueOnce(jsonResponse({ admin_user: admin }))
      .mockResolvedValueOnce(emptyResponse());
    renderAuth();
    expect(await screen.findByTestId("email")).toHaveTextContent("hr@example.com");

    screen.getByRole("button", { name: "Log out" }).click();

    expect(await screen.findByTestId("email")).toHaveTextContent("none");
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
  });

  it("signs the admin out when the API reports that the session is unauthorized", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ admin_user: admin }));
    renderAuth();
    expect(await screen.findByTestId("email")).toHaveTextContent("hr@example.com");

    window.dispatchEvent(new Event("auth:unauthorized"));

    await vi.waitFor(() => expect(screen.getByTestId("email")).toHaveTextContent("none"));
  });
});

describe("useAuth", () => {
  it("requires an auth provider", () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);

    expect(() => render(<Probe />)).toThrow("useAuth must be used within AuthProvider");
  });
});

describe("isApiError", () => {
  it("recognizes ApiError instances", () => {
    expect(isApiError(new ApiError("nope", 422))).toBe(true);
    expect(isApiError(new Error("nope"))).toBe(false);
    expect(isApiError({ name: "ApiError" })).toBe(false);
  });
});
