import { AUTH_TOKEN_KEY, ApiError, api, errorMessage, fieldErrors } from "./client";
import { emptyResponse, jsonResponse } from "../test/http";

const base = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000";

function requestHeaders(callIndex = 0) {
  const init = vi.mocked(fetch).mock.calls[callIndex]?.[1];
  return new Headers(init?.headers);
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn());
});

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("api", () => {
  it("sends JSON and the stored bearer token", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ ok: true }));

    await expect(api("/api/v1/employees", { method: "POST", body: { name: "Ada" } })).resolves.toEqual({
      ok: true,
    });

    const init = vi.mocked(fetch).mock.calls[0][1];
    const headers = requestHeaders();
    expect(vi.mocked(fetch).mock.calls[0][0]).toBe(`${base}/api/v1/employees`);
    expect(init?.method).toBe("POST");
    expect(init?.body).toBe(JSON.stringify({ name: "Ada" }));
    expect(headers.get("Accept")).toBe("application/json");
    expect(headers.get("Content-Type")).toBe("application/json");
    expect(headers.get("Authorization")).toBe("Bearer secret");
  });

  it("omits the content type and authorization header when they are not needed", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse([]));

    await api("/api/v1/currencies", { headers: { "X-Test": "1" } });

    const headers = requestHeaders();
    expect(headers.get("Content-Type")).toBeNull();
    expect(headers.get("Authorization")).toBeNull();
    expect(headers.get("X-Test")).toBe("1");
  });

  it("returns undefined for an empty response", async () => {
    vi.mocked(fetch).mockResolvedValue(emptyResponse());

    await expect(api("/api/v1/session", { method: "DELETE" })).resolves.toBeUndefined();
  });

  it("clears the session and notifies the app on an authenticated 401", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    const onUnauthorized = vi.fn();
    window.addEventListener("auth:unauthorized", onUnauthorized);
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "Session expired" }, 401));

    await expect(api("/api/v1/employees")).rejects.toMatchObject({
      name: "ApiError",
      message: "Session expired",
      status: 401,
    });
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
    expect(onUnauthorized).toHaveBeenCalledOnce();

    window.removeEventListener("auth:unauthorized", onUnauthorized);
  });

  it("leaves the session alone when a logged-out request is rejected", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    const onUnauthorized = vi.fn();
    window.addEventListener("auth:unauthorized", onUnauthorized);
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "Invalid email or password" }, 401));

    await expect(api("/api/v1/session", { method: "POST", auth: false, body: {} })).rejects.toBeInstanceOf(
      ApiError,
    );
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBe("secret");
    expect(onUnauthorized).not.toHaveBeenCalled();

    window.removeEventListener("auth:unauthorized", onUnauthorized);
  });

  it("normalizes field errors from a failed response", async () => {
    vi.mocked(fetch).mockResolvedValue(
      jsonResponse({ error: "invalid", errors: { email: ["taken", "invalid"], salary: "bad" } }, 422),
    );

    const error = await api("/api/v1/employees", { method: "POST", body: {} }).catch((caught: unknown) => caught);

    expect(error).toBeInstanceOf(ApiError);
    expect(fieldErrors(error)).toEqual({ email: "taken, invalid", salary: "bad" });
    expect(errorMessage(error)).toBe("email taken, invalid; salary bad");
  });

  it("uses a generic message when the error body is not JSON", async () => {
    vi.mocked(fetch).mockResolvedValue(new Response("nope", { status: 500 }));

    await expect(api("/api/v1/employees")).rejects.toMatchObject({
      message: "Request failed",
      status: 500,
    });
  });

  it("ignores an errors payload that is not an object", async () => {
    vi.mocked(fetch).mockResolvedValue(jsonResponse({ error: "nope", errors: "bad" }, 422));

    const error = await api("/api/v1/employees").catch((caught: unknown) => caught);
    expect(errorMessage(error)).toBe("nope");
    expect(fieldErrors(error)).toEqual({});
  });
});

describe("error helpers", () => {
  it("reads an ApiError message when there are no field details", () => {
    expect(errorMessage(new ApiError("Saved failed", 500))).toBe("Saved failed");
    expect(errorMessage(new ApiError("Saved failed", 422, {}))).toBe("Saved failed");
    expect(fieldErrors(new ApiError("Saved failed", 500))).toEqual({});
  });

  it("reads a generic error and hides unknown values", () => {
    expect(errorMessage(new Error("Network down"))).toBe("Network down");
    expect(errorMessage("nope")).toBe("Something went wrong");
    expect(fieldErrors(new Error("Network down"))).toEqual({});
  });
});
