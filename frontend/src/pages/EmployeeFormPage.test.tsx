import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { api } from "../api/client";
import { catalogResponse, employee } from "../test/fixtures";
import { chooseOption, renderWithProviders } from "../test/render";
import { EmployeeFormPage } from "./EmployeeFormPage";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

function renderCreate() {
  return renderWithProviders(
    <Routes>
      <Route path="/employees/new" element={<EmployeeFormPage />} />
      <Route path="/employees/:id" element={<h1>Saved employee</h1>} />
      <Route path="/directory" element={<h1>Directory</h1>} />
    </Routes>,
    { route: "/employees/new" },
  );
}

function renderEdit() {
  return renderWithProviders(
    <Routes>
      <Route path="/employees/:id/edit" element={<EmployeeFormPage />} />
      <Route path="/employees/:id" element={<h1>Saved employee</h1>} />
    </Routes>,
    { route: "/employees/5/edit" },
  );
}

beforeEach(() => {
  vi.mocked(api).mockImplementation(async (path) => {
    const catalog = catalogResponse(path);
    if (catalog) return catalog;
    if (path === "/api/v1/employees/5") return { employee: employee() };
    if (path === "/api/v1/employees") return { employee: employee({ id: 8 }) };
    throw new Error(`Unhandled ${path}`);
  });
});

describe("EmployeeFormPage", () => {
  it("requires the compensation fields before creating an employee", async () => {
    const { user } = renderCreate();

    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(screen.getByText("Enter an employee number")).toBeInTheDocument();
    expect(screen.getByText("Enter a first name")).toBeInTheDocument();
    expect(screen.getByText("Enter a last name")).toBeInTheDocument();
    expect(screen.getByText("Enter a valid email")).toBeInTheDocument();
    expect(screen.getByText("Choose a country")).toBeInTheDocument();
    expect(screen.getByText("Choose a department")).toBeInTheDocument();
    expect(screen.getByText("Choose a job title")).toBeInTheDocument();
    expect(screen.getByText("Choose a level")).toBeInTheDocument();
    expect(screen.getByText("Choose a hire date")).toBeInTheDocument();
    expect(api).not.toHaveBeenCalledWith("/api/v1/employees", expect.anything());
  });

  it("requires a termination date when the employee is terminated", async () => {
    const { user } = renderCreate();

    await chooseOption(user, "Status", "Terminated");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(screen.getByLabelText("Termination date")).toBeInTheDocument();
    expect(screen.getByText("Choose a termination date")).toBeInTheDocument();
  });

  it("creates an employee and opens the new profile", async () => {
    const { user } = renderCreate();
    await chooseOption(user, "Country", "India");
    await chooseOption(user, "Department", "Engineering");
    await chooseOption(user, "Job title", "Engineer");
    await chooseOption(user, "Level", "Senior");
    await user.type(screen.getByLabelText("Employee number"), "E-1000");
    await user.type(screen.getByLabelText("Email"), "ada@example.com");
    await user.type(screen.getByLabelText("First name"), "Ada");
    await user.type(screen.getByLabelText("Last name"), "Lovelace");
    await user.type(screen.getByLabelText("Hire date"), "2020-01-15");
    await user.type(screen.getByLabelText("Manager id"), "12");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByRole("heading", { name: "Saved employee" })).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/employees", {
      method: "POST",
      body: {
        employee: {
          employee_number: "E-1000",
          first_name: "Ada",
          last_name: "Lovelace",
          email: "ada@example.com",
          country_id: 10,
          department_id: 20,
          job_title_id: 30,
          employment_level_id: 40,
          manager_id: 12,
          employment_status: "active",
          hire_date: "2020-01-15",
          termination_date: null,
        },
      },
    });
    expect(await screen.findByText("Employee created")).toBeInTheDocument();
  });

  it("drops the title and level when the department changes", async () => {
    const { user } = renderCreate();

    await chooseOption(user, "Department", "Engineering");
    await chooseOption(user, "Job title", "Engineer");
    await chooseOption(user, "Level", "Senior");
    await chooseOption(user, "Department", "Finance");

    await user.click(screen.getByRole("combobox", { name: "Job title" }));
    expect(await screen.findByRole("option", { name: "Accountant" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Engineer" })).not.toBeInTheDocument();
    await user.keyboard("{Escape}");

    await user.click(screen.getByRole("combobox", { name: "Level" }));
    expect((await screen.findAllByRole("option")).map((option) => option.textContent)).toEqual([
      "Junior",
      "Senior",
    ]);
  });

  it("updates an existing employee", async () => {
    const { user } = renderEdit();

    expect(await screen.findByDisplayValue("E-0005")).toBeInTheDocument();
    expect(await screen.findByDisplayValue("India")).toBeInTheDocument();
    const firstName = screen.getByLabelText("First name");
    await user.clear(firstName);
    await user.type(firstName, "Augusta");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByRole("heading", { name: "Saved employee" })).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/employees/5", {
      method: "PATCH",
      body: {
        employee: expect.objectContaining({
          first_name: "Augusta",
          last_name: "Lovelace",
          country_id: 10,
          department_id: 20,
          job_title_id: 30,
          employment_level_id: 40,
          manager_id: null,
          termination_date: null,
        }),
      },
    });
    expect(await screen.findByText("Employee updated")).toBeInTheDocument();
  });

  it("returns to the directory when creating is cancelled", async () => {
    const { user } = renderCreate();

    await user.click(screen.getByRole("link", { name: "Cancel" }));

    expect(screen.getByRole("heading", { name: "Directory" })).toBeInTheDocument();
  });
});
