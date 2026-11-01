import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { api } from "../api/client";
import type { DirectoryResponse, Employee } from "../api/types";
import { resetAuth } from "../test/authState";
import { catalogResponse, employee } from "../test/fixtures";
import { formatMoney } from "../components/format";
import { renderWithProviders } from "../test/render";
import { DirectoryPage } from "./DirectoryPage";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

vi.mock("../auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("../auth/AuthContext")>("../auth/AuthContext");
  const { authState } = await import("../test/authState");
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
      unconverted_count: 0,
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
    expect(row).toHaveTextContent(formatMoney(person.current_compensation?.reporting_amount, "USD"));
    expect(screen.getByText(/reporting column is USD/)).toBeInTheDocument();
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
                reporting_amount: null,
              },
            }),
          ],
          { total_count: 2, per_page: 20, unconverted_count: 1 },
        );
      }
      throw new Error(`Unhandled ${path}`);
    });
    renderDirectory();

    expect(await screen.findByText("No current salary")).toBeInTheDocument();
    expect(screen.getByText("No rate")).toBeInTheDocument();
    expect(screen.getByText(/1 employees in the unfiltered salary set have no exchange rate/)).toBeInTheDocument();
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
