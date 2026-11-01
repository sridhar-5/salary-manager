import { screen } from "@testing-library/react";
import { api } from "../api/client";
import { resetAuth } from "../test/authState";
import { catalogResponse, salaryBand } from "../test/fixtures";
import { formatMoney } from "../components/format";
import { renderWithProviders } from "../test/render";
import { SalaryBandsPage } from "./SalaryBandsPage";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

vi.mock("../auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("../auth/AuthContext")>("../auth/AuthContext");
  const { authState } = await import("../test/authState");
  return { ...actual, useAuth: () => authState };
});

beforeEach(() => {
  resetAuth();
  vi.mocked(api).mockImplementation(async (path) => {
    const catalog = catalogResponse(path);
    if (catalog) return catalog;
    if (path.startsWith("/api/v1/salary_bands")) return { salary_bands: [salaryBand()] };
    throw new Error(`Unhandled ${path}`);
  });
});

describe("SalaryBandsPage", () => {
  it("lists a band in the catalog labels", async () => {
    renderWithProviders(<SalaryBandsPage />);

    expect(await screen.findByRole("cell", { name: "India" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Engineering" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Engineer" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Senior" })).toBeInTheDocument();
    const band = salaryBand();
    const minimum = formatMoney(band.min_salary, "INR");
    const maximum = formatMoney(band.max_salary, "INR");
    expect(screen.getByRole("cell", { name: (name) => name.includes(minimum) && name.includes(maximum) })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: /2024-01-01/ })).toHaveTextContent("open");
    expect(screen.getByRole("button", { name: "Add band" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Edit" })).toBeInTheDocument();
  });

  it("hides editing from viewers", async () => {
    resetAuth({ id: 2, email: "viewer@example.com", roles: ["viewer"] });
    renderWithProviders(<SalaryBandsPage />);

    expect(await screen.findByRole("cell", { name: "India" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Add band" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Edit" })).not.toBeInTheDocument();
  });

  it("shows an empty state", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      if (path.startsWith("/api/v1/salary_bands")) return { salary_bands: [] };
      throw new Error(`Unhandled ${path}`);
    });
    renderWithProviders(<SalaryBandsPage />);

    expect(await screen.findByText("No salary bands yet.")).toBeInTheDocument();
  });

  it("shows a load error", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      throw new Error("Bands unavailable");
    });
    renderWithProviders(<SalaryBandsPage />);

    expect(await screen.findByRole("alert")).toHaveTextContent("Bands unavailable");
  });
});
