import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { api } from "@/shared/api/client";
import type { DirectoryResponse, Employee } from "@/features/directory/types";
import { resetAuth } from "@/shared/test/authState";
import { catalogResponse, employee } from "@/shared/test/fixtures";
import { usdSalary } from "@/features/directory/format";
import { formatMoney } from "@/shared/format/format";
import { renderWithProviders } from "@/shared/test/render";
import { DirectoryPage } from "./DirectoryPage";

vi.mock("@/shared/api/client", async () => {
  const actual = await vi.importActual<typeof import("@/shared/api/client")>("@/shared/api/client");
  return { ...actual, api: vi.fn() };
});

vi.mock("@/features/auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("@/features/auth/AuthContext")>("@/features/auth/AuthContext");
  const { authState } = await import("@/shared/test/authState");
  return { ...actual, useAuth: () => authState };
});

function directory(employees: Employee[], meta: Partial<DirectoryResponse["meta"]> = {}): DirectoryResponse {
  return {
    employees,
    meta: {
      page: 1,
      per_page: 1,
      total_count: employees.length,
      total_pages: 1,
      reporting_currency: { id: 1, code: "USD", name: "US Dollar" },
      ...meta,
    },
  };
}

function renderDirectory(route = "/directory") {
  return renderWithProviders(
    <Routes>
      <Route path="/directory" element={<DirectoryPage />} />
      <Route path="/employees/new" element={<h1>New employee</h1>} />
      <Route path="/employees/:id" element={<h1>Employee profile</h1>} />
    </Routes>,
    { route },
  );
}

beforeEach(() => {
  resetAuth();
  vi.mocked(api).mockImplementation(async (path) => {
    const catalog = catalogResponse(path);
    if (catalog) return catalog;
    if (path.startsWith("/api/v1/employees")) return directory([employee()]);
    throw new Error(`Unhandled ${path}`);
  });
});

describe("DirectoryPage", () => {
  it("lists employees and links to a profile", async () => {
    const person = employee();
    const { user } = renderDirectory();

    expect(await screen.findByRole("link", { name: "Ada Lovelace" })).toBeInTheDocument();
    const row = screen.getByRole("row", { name: /Ada Lovelace/ });
    expect(row).toHaveTextContent("E-0005");
    expect(row).toHaveTextContent("Engineering");
    expect(row).toHaveTextContent("Engineer");
    expect(row).toHaveTextContent("Senior");
    expect(row).toHaveTextContent("India");
    expect(row).toHaveTextContent("active");
    expect(row).toHaveTextContent(formatMoney(person.current_compensation?.annual_salary, "INR"));
    expect(row).toHaveTextContent(usdSalary(person.current_compensation));
    expect(screen.getByText(/USD is that salary divided by the USD rate/)).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Add employee" })).toHaveAttribute("href", "/employees/new");

    await user.click(screen.getByRole("link", { name: "Ada Lovelace" }));
    expect(screen.getByRole("heading", { name: "Employee profile" })).toBeInTheDocument();
  });

  it("explains a missing salary and a missing exchange rate", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      if (path.startsWith("/api/v1/employees")) {
        return directory(
          [
            employee({ id: 6, current_compensation: null, employee_number: "E-0006", first_name: "Grace" }),
            employee({
              id: 7,
              first_name: "Lin",
              current_compensation: {
                id: 2,
                annual_salary: "90000",
                currency: { id: 2, code: "INR" },
                effective_from: "2024-01-01",
                effective_to: null,
                usd_rate: null,
              },
            }),
          ],
          { total_count: 2, per_page: 20 },
        );
      }
      throw new Error(`Unhandled ${path}`);
    });
    renderDirectory();

    expect(await screen.findByText("No current salary")).toBeInTheDocument();
    expect(screen.getByText("No rate")).toBeInTheDocument();
  });

  it("hides employee creation from people who cannot manage compensation", async () => {
    resetAuth({ id: 2, email: "viewer@example.com", roles: ["viewer"] });
    renderDirectory();

    expect(await screen.findByRole("link", { name: "Ada Lovelace" })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Add employee" })).not.toBeInTheDocument();
  });

  it("shows an empty state when nothing matches", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      if (path.startsWith("/api/v1/employees")) return directory([], { total_count: 0 });
      throw new Error(`Unhandled ${path}`);
    });
    renderDirectory();

    expect(await screen.findByText("No employees match these filters.")).toBeInTheDocument();
  });

  it("shows the request error", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      throw new Error("Directory unavailable");
    });
    renderDirectory();

    expect(await screen.findByRole("alert")).toHaveTextContent("Directory unavailable");
  });

  it("sends the minimum salary filter with the directory request", async () => {
    renderDirectory("/directory?filters[min_salary]=100000");

    expect(await screen.findByRole("link", { name: "Ada Lovelace" })).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith(
      expect.stringContaining("/api/v1/employees?filters%5Bmin_salary%5D=100000"),
    );
  });

  it("requests the selected page", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      if (path.startsWith("/api/v1/employees")) {
        return directory([employee()], { total_count: 2, total_pages: 2, per_page: 1 });
      }
      throw new Error(`Unhandled ${path}`);
    });
    const { user } = renderDirectory();

    await user.click(await screen.findByRole("button", { name: "2" }));

    await vi.waitFor(() =>
      expect(api).toHaveBeenCalledWith(expect.stringContaining("/api/v1/employees?page=2")),
    );
  });
});
