import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { api } from "../api/client";
import { resetAuth } from "../test/authState";
import { compensationRecord, employee, payslip } from "../test/fixtures";
import { formatMoney } from "../components/format";
import { renderWithProviders } from "../test/render";
import { EmployeePage } from "./EmployeePage";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

vi.mock("../auth/AuthContext", async () => {
  const actual = await vi.importActual<typeof import("../auth/AuthContext")>("../auth/AuthContext");
  const { authState } = await import("../test/authState");
  return { ...actual, useAuth: () => authState };
});

function renderEmployee(route = "/employees/5") {
  return renderWithProviders(
    <Routes>
      <Route path="/employees/:id" element={<EmployeePage />} />
      <Route path="/employees/:id/edit" element={<h1>Edit employee</h1>} />
    </Routes>,
    { route },
  );
}

beforeEach(() => {
  resetAuth();
  vi.mocked(api).mockImplementation(async (path) => {
    if (path.includes("/compensation_records") && !path.endsWith("/compensation_records")) return undefined;
    if (path.includes("/compensation_records")) {
      return { compensation_records: [compensationRecord()] };
    }
    if (path.startsWith("/api/v1/employees/5")) {
      return { employee: employee({ payslips: [payslip()] }) };
    }
    throw new Error(`Unhandled ${path}`);
  });
});

describe("EmployeePage", () => {
  it("shows the profile, payslip, and compensation audit", async () => {
    const { user } = renderEmployee("/employees/5?reporting_currency_id=1&page=2");

    expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
    expect(screen.getByText("E-0005 · ada@example.com")).toBeInTheDocument();
    expect(screen.getByText("India (IN)")).toBeInTheDocument();
    expect(screen.getByText("2020-01-15")).toBeInTheDocument();
    expect(screen.getByText(formatMoney("120000", "INR"))).toBeInTheDocument();
    expect(screen.getByText(formatMoney("1500", "USD"))).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/employees/5?reporting_currency_id=1");

    expect(screen.getByText("PS-7")).toBeInTheDocument();
    expect(screen.getByText("2024-01-01 – 2024-01-31")).toBeInTheDocument();
    expect(screen.getByText(formatMoney("10000.50", "INR", 2))).toBeInTheDocument();
    expect(screen.getByText("paid")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: /hr@example.com/ }));
    expect(await screen.findByText(/by unknown/)).toHaveTextContent("effective_to: empty → 2024-12-31");
    expect(screen.getByRole("link", { name: "Edit employee" })).toHaveAttribute("href", "/employees/5/edit");
  });

  it("hides compensation actions from viewers", async () => {
    resetAuth({ id: 2, email: "viewer@example.com", roles: ["viewer"] });
    renderEmployee();

    expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Edit employee" })).not.toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Add salary" })).not.toBeInTheDocument();
  });

  it("says when there is no salary, payslip, or history", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      if (path.includes("/compensation_records")) return { compensation_records: [] };
      if (path.startsWith("/api/v1/employees/5")) {
        return {
          employee: employee({
            current_compensation: null,
            payslips: [],
            manager: { id: 2, first_name: "Grace", last_name: "Hopper", employee_number: "E-0002" },
          }),
        };
      }
      throw new Error(`Unhandled ${path}`);
    });
    renderEmployee();

    expect(await screen.findByText("No current salary")).toBeInTheDocument();
    expect(screen.getByText("No payslips yet.")).toBeInTheDocument();
    expect(await screen.findByText("No compensation records yet.")).toBeInTheDocument();
    expect(screen.getByText("Grace Hopper (E-0002)")).toBeInTheDocument();
  });

  it("records a new salary and rejects an empty one", async () => {
    const { user } = renderEmployee();
    expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Add salary" }));
    await user.click(await screen.findByRole("button", { name: "Save salary" }));
    expect(screen.getByText("Enter a salary greater than zero")).toBeInTheDocument();
    expect(screen.getByText("Choose the date this salary takes effect")).toBeInTheDocument();

    await user.type(screen.getByLabelText("Annual salary"), "0");
    await user.click(screen.getByRole("button", { name: "Save salary" }));
    expect(screen.getByText("Enter a salary greater than zero")).toBeInTheDocument();

    await user.clear(screen.getByLabelText("Annual salary"));
    await user.type(screen.getByLabelText("Annual salary"), "88000");
    await user.type(screen.getByLabelText("Effective from"), "2024-05-01");
    await user.click(screen.getByRole("button", { name: "Save salary" }));

    expect(await screen.findByText("Salary recorded")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/employees/5/compensation_records", {
      method: "POST",
      body: {
        compensation_record: {
          annual_salary: "88000",
          effective_from: "2024-05-01",
        },
      },
    });
  });

  it("clears the end date of a compensation record", async () => {
    const { user } = renderEmployee();
    expect(await screen.findByRole("heading", { name: "Ada Lovelace" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: /hr@example.com/ }));
    await user.click(await screen.findByRole("button", { name: "Edit end date" }));
    await user.clear(screen.getByLabelText("Effective to"));
    await user.click(screen.getByRole("button", { name: "Save end date" }));

    expect(await screen.findByText("End date updated")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/employees/5/compensation_records/9", {
      method: "PATCH",
      body: { compensation_record: { effective_to: null } },
    });
  });
});
