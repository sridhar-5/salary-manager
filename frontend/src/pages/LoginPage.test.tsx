import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { AUTH_TOKEN_KEY } from "../api/client";
import { jsonResponse } from "../test/http";
import { renderWithProviders } from "../test/render";
import { LoginPage } from "./LoginPage";

const admin = { id: 1, email: "hr@example.com", roles: ["compensation_admin"] };

function renderLogin() {
  return renderWithProviders(
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/directory" element={<h1>Directory</h1>} />
    </Routes>,
    { route: "/login" },
  );
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn());
});

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("LoginPage", () => {
  it("asks for an email and password before submitting", async () => {
    const { user } = renderLogin();

    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(screen.getByText("Enter a valid email")).toBeInTheDocument();
    expect(screen.getByText("Enter your password")).toBeInTheDocument();
    expect(fetch).not.toHaveBeenCalled();
  });

  it("rejects an email without @", async () => {
    const { user } = renderLogin();

    await user.type(screen.getByLabelText("Email"), "hr.example.com");
    await user.type(screen.getByLabelText("Password"), "password");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(screen.getByText("Enter a valid email")).toBeInTheDocument();
    expect(fetch).not.toHaveBeenCalled();
  });

  it("signs in and opens the directory", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ token: "secret", admin_user: admin }));
    const { user } = renderLogin();

    await user.type(screen.getByLabelText("Email"), "hr@example.com");
    await user.type(screen.getByLabelText("Password"), "password");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(await screen.findByRole("heading", { name: "Directory" })).toBeInTheDocument();
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBe("secret");
    expect(vi.mocked(fetch).mock.calls[0][1]?.body).toBe(
      JSON.stringify({ email: "hr@example.com", password: "password" }),
    );
  });

  it("shows a rejected login on the password field", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "Invalid email or password" }, 401));
    const { user } = renderLogin();

    await user.type(screen.getByLabelText("Email"), "hr@example.com");
    await user.type(screen.getByLabelText("Password"), "wrong");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(await screen.findByText("Invalid email or password")).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Directory" })).not.toBeInTheDocument();
  });

  it("shows field errors returned by the API", async () => {
    vi.mocked(fetch).mockResolvedValue(
      jsonResponse({ error: "invalid", errors: { email: ["is not an email"] } }, 422),
    );
    const { user } = renderLogin();

    await user.type(screen.getByLabelText("Email"), "hr@example.com");
    await user.type(screen.getByLabelText("Password"), "password");
    await user.click(screen.getByRole("button", { name: "Sign in" }));

    expect(await screen.findByText("is not an email")).toBeInTheDocument();
  });

  it("sends an already signed-in admin to the directory", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ admin_user: admin }));

    renderLogin();

    expect(await screen.findByRole("heading", { name: "Directory" })).toBeInTheDocument();
  });
});
