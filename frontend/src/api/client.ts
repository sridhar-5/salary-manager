const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000";

export const AUTH_TOKEN_KEY = "auth_token";

export class ApiError extends Error {
  status: number;
  errors?: Record<string, string[]>;

  constructor(message: string, status: number, errors?: Record<string, string[]>) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.errors = errors;
  }
}

type ApiOptions = Omit<RequestInit, "body"> & {
  body?: unknown;
  auth?: boolean;
};

export async function api<T>(path: string, options: ApiOptions = {}): Promise<T> {
  const { auth = true, body, headers, ...rest } = options;
  const requestHeaders = new Headers(headers);
  requestHeaders.set("Accept", "application/json");
  if (body !== undefined) requestHeaders.set("Content-Type", "application/json");

  const token = sessionStorage.getItem(AUTH_TOKEN_KEY);
  if (token) requestHeaders.set("Authorization", `Bearer ${token}`);

  const response = await fetch(`${API_BASE}${path}`, {
    ...rest,
    headers: requestHeaders,
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (response.status === 401 && auth) {
    sessionStorage.removeItem(AUTH_TOKEN_KEY);
    window.dispatchEvent(new Event("auth:unauthorized"));
  }

  if (response.status === 204) return undefined as T;

  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = typeof payload.error === "string" ? payload.error : "Request failed";
    throw new ApiError(message, response.status, normalizeErrors(payload.errors));
  }

  return payload as T;
}

function normalizeErrors(errors: unknown): Record<string, string[]> | undefined {
  if (!errors || typeof errors !== "object") return undefined;

  return Object.fromEntries(
    Object.entries(errors as Record<string, unknown>).map(([key, value]) => [
      key,
      Array.isArray(value) ? value.map(String) : [String(value)],
    ]),
  );
}

export function fieldErrors(error: unknown): Record<string, string> {
  if (!(error instanceof ApiError) || !error.errors) return {};
  return Object.fromEntries(
    Object.entries(error.errors).map(([key, messages]) => [key, messages.join(", ")]),
  );
}

export function errorMessage(error: unknown) {
  if (error instanceof ApiError) {
    if (error.errors) {
      const details = Object.entries(error.errors)
        .map(([field, messages]) => `${field} ${messages.join(", ")}`)
        .join("; ");
      if (details) return details;
    }
    return error.message;
  }
  if (error instanceof Error) return error.message;
  return "Something went wrong";
}
