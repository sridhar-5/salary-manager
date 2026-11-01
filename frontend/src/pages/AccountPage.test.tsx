import { screen } from "@testing-library/react";
import { ApiError, api } from "../api/client";
import { authState, resetAuth } from "../test/authState";
import { renderWithProviders } from "../test/render";
import { AccountPage } from "./AccountPage";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

vi.mock("../auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("../auth/AuthContext")>("../auth/AuthContext");
  const auth = await import("../test/authState");
  return { ...actual, useAuth: () => auth.authState };
});

beforeEach(() => {
  resetAuth({ id: 1, email: "hr@example.com", roles: ["super_admin", "compensation_admin"] });
  vi.mocked(api).mockResolvedValue(undefined);
});

describe("AccountPage", () => {
  it("shows the signed-in admin", () => {
    renderWithProviders(<AccountPage />);

    expect(screen.getByText(/hr@example.com/)).toBeInTheDocument();
    expect(screen.getByText(/super_admin, compensation_admin/)).toBeInTheDocument();
  });

  it("requires the current password, a long enough new password, and a matching confirmation", async () => {
    const { user } = renderWithProviders(<AccountPage />);

    await user.click(screen.getByRole("button", { name: "Update password" }));
    expect(screen.getByText("Enter your current password")).toBeInTheDocument();
    expect(screen.getByText("Use at least 6 characters")).toBeInTheDocument();

    await user.type(screen.getByLabelText("Current password"), "old-password");
    await user.type(screen.getByLabelText("New password"), "short");
    await user.type(screen.getByLabelText("Confirm new password"), "other");
    await user.click(screen.getByRole("button", { name: "Update password" }));

    expect(screen.getByText("Use at least 6 characters")).toBeInTheDocument();
    expect(screen.getByText("Passwords do not match")).toBeInTheDocument();
    expect(api).not.toHaveBeenCalled();
  });

  it("updates the password and clears the form", async () => {
    const { user } = renderWithProviders(<AccountPage />);

    await user.type(screen.getByLabelText("Current password"), "old-password");
    await user.type(screen.getByLabelText("New password"), "new-password");
    await user.type(screen.getByLabelText("Confirm new password"), "new-password");
    await user.click(screen.getByRole("button", { name: "Update password" }));

    expect(await screen.findByText("Password updated")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/password", {
      method: "PATCH",
      body: {
        current_password: "old-password",
        password: "new-password",
        password_confirmation: "new-password",
      },
    });
    expect(screen.getByLabelText("New password")).toHaveValue("");
  });

  it("shows field errors from the API", async () => {
    vi.mocked(api).mockRejectedValue(new ApiError("invalid", 422, { current_password: ["is incorrect"] }));
    const { user } = renderWithProviders(<AccountPage />);

    await user.type(screen.getByLabelText("Current password"), "old-password");
    await user.type(screen.getByLabelText("New password"), "new-password");
    await user.type(screen.getByLabelText("Confirm new password"), "new-password");
    await user.click(screen.getByRole("button", { name: "Update password" }));

    expect(await screen.findByText("is incorrect")).toBeInTheDocument();
    expect(authState.admin?.email).toBe("hr@example.com");
  });

  it("shows a notification when the request fails without field errors", async () => {
    vi.mocked(api).mockRejectedValue(new Error("Password service unavailable"));
    const { user } = renderWithProviders(<AccountPage />);

    await user.type(screen.getByLabelText("Current password"), "old-password");
    await user.type(screen.getByLabelText("New password"), "new-password");
    await user.type(screen.getByLabelText("Confirm new password"), "new-password");
    await user.click(screen.getByRole("button", { name: "Update password" }));

    expect(await screen.findByText("Password service unavailable")).toBeInTheDocument();
  });
});
