import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { authState, resetAuth } from "../test/authState";
import { renderWithProviders } from "../test/render";
import { AppLayout } from "./AppLayout";

vi.mock("../auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("../auth/AuthContext")>("../auth/AuthContext");
  const { authState } = await import("../test/authState");
  return { ...actual, useAuth: () => authState };
});

function renderLayout(route: string) {
  return renderWithProviders(
    <Routes>
      <Route element={<AppLayout />}>
        <Route path="/directory" element={<h1>Directory</h1>} />
        <Route path="/employees/:id" element={<h1>Employee</h1>} />
        <Route path="/salary-bands" element={<h1>Salary bands</h1>} />
        <Route path="/exchange-rates" element={<h1>Exchange rates</h1>} />
        <Route path="/reference" element={<h1>Reference</h1>} />
        <Route path="/account" element={<h1>Account</h1>} />
      </Route>
      <Route path="/login" element={<h1>Login</h1>} />
    </Routes>,
    { route },
  );
}

beforeEach(() => {
  resetAuth();
});

describe("AppLayout", () => {
  it("shows reference data only to super admins", () => {
    resetAuth({ id: 1, email: "hr@example.com", roles: ["super_admin"] });
    renderLayout("/directory");

    expect(screen.getByRole("link", { name: "Reference data" })).toHaveAttribute("href", "/reference");
  });

  it("hides reference data from compensation admins", () => {
    renderLayout("/directory");

    expect(screen.queryByRole("link", { name: "Reference data" })).not.toBeInTheDocument();
  });

  it("keeps directory filters on the directory link and marks employee pages active", () => {
    renderLayout("/employees/5?search=ada&page=2&limit=50&filters[with_country_id]=10");

    expect(screen.getByRole("link", { name: "Directory" })).toHaveAttribute(
      "href",
      "/directory?search=ada&filters%5Bwith_country_id%5D=10",
    );
    expect(screen.getByRole("link", { name: "Directory" })).toHaveAttribute("data-active", "true");
    expect(screen.getByRole("link", { name: "Salary bands" })).toHaveAttribute("href", "/salary-bands");
    expect(screen.getByRole("link", { name: "Salary bands" })).not.toHaveAttribute("data-active");
  });

  it("marks the matching section active", () => {
    renderLayout("/salary-bands");

    expect(screen.getByRole("link", { name: "Salary bands" })).toHaveAttribute("data-active", "true");
    expect(screen.getByRole("link", { name: "Directory" })).not.toHaveAttribute("data-active");
  });

  it("logs out and returns to the login page", async () => {
    const { user } = renderLayout("/directory");

    await user.click(screen.getByRole("button", { name: "hr@example.com" }));
    await user.click(await screen.findByRole("menuitem", { name: "Log out" }));

    expect(await screen.findByRole("heading", { name: "Login" })).toBeInTheDocument();
    expect(authState.logout).toHaveBeenCalledOnce();
  });
});
