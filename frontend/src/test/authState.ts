import { vi } from "vitest";
import type { AdminUser } from "../api/types";

const defaultAdmin: AdminUser = {
  id: 1,
  email: "hr@example.com",
  roles: ["compensation_admin"],
};

export const authState: {
  admin: AdminUser | null;
  loading: boolean;
  login: ReturnType<typeof vi.fn>;
  logout: ReturnType<typeof vi.fn>;
} = {
  admin: defaultAdmin,
  loading: false,
  login: vi.fn(),
  logout: vi.fn(async () => undefined),
};

export function resetAuth(admin: AdminUser | null = defaultAdmin) {
  authState.admin = admin;
  authState.loading = false;
  authState.login.mockReset();
  authState.logout.mockReset();
  authState.logout.mockResolvedValue(undefined);
}
