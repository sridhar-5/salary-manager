import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { api, AUTH_TOKEN_KEY, type ApiError } from "../api/client";
import type { AdminUser } from "../api/types";

type AuthContextValue = {
  admin: AdminUser | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [admin, setAdmin] = useState<AdminUser | null>(null);
  const [loading, setLoading] = useState(() => Boolean(sessionStorage.getItem(AUTH_TOKEN_KEY)));

  useEffect(() => {
    const token = sessionStorage.getItem(AUTH_TOKEN_KEY);
    if (!token) return undefined;

    api<{ admin_user: AdminUser }>("/api/v1/session")
      .then((body) => setAdmin(body.admin_user))
      .catch(() => {
        sessionStorage.removeItem(AUTH_TOKEN_KEY);
        setAdmin(null);
      })
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    const onUnauthorized = () => setAdmin(null);
    window.addEventListener("auth:unauthorized", onUnauthorized);
    return () => window.removeEventListener("auth:unauthorized", onUnauthorized);
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      admin,
      loading,
      async login(email, password) {
        const body = await api<{ token: string; admin_user: AdminUser }>("/api/v1/session", {
          method: "POST",
          auth: false,
          body: { email, password },
        });
        sessionStorage.setItem(AUTH_TOKEN_KEY, body.token);
        setAdmin(body.admin_user);
      },
      async logout() {
        try {
          await api("/api/v1/session", { method: "DELETE" });
        } catch {
          sessionStorage.removeItem(AUTH_TOKEN_KEY);
        }
        sessionStorage.removeItem(AUTH_TOKEN_KEY);
        setAdmin(null);
      },
    }),
    [admin, loading],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error("useAuth must be used within AuthProvider");
  return value;
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof Error && error.name === "ApiError";
}
