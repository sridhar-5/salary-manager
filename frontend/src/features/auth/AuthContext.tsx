import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import type { AdminUser } from "@/features/auth/types";
import { api, AUTH_TOKEN_KEY, type ApiError } from "@/shared/api/client";

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

    const controller = new AbortController();
    api<{ admin_user: AdminUser }>("/api/v1/session", { signal: controller.signal })
      .then((body) => {
        if (!controller.signal.aborted) setAdmin(body.admin_user);
      })
      .catch(() => {
        if (controller.signal.aborted) return;
        sessionStorage.removeItem(AUTH_TOKEN_KEY);
        setAdmin(null);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
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
