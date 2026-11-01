import { screen } from "@testing-library/react";
import { Route, Routes } from "react-router";
import { api } from "../api/client";
import { catalogResponse } from "../test/fixtures";
import { renderWithProviders } from "../test/render";
import { CompensationFilters } from "./CompensationFilters";
import { useSearchParams } from "react-router";

vi.mock("../api/client", async () => {
  const actual = await vi.importActual<typeof import("../api/client")>("../api/client");
  return { ...actual, api: vi.fn() };
});

function QueryProbe() {
  const [params] = useSearchParams();
  return <div data-testid="query">{params.toString()}</div>;
}

function renderFilters(route: string) {
  return renderWithProviders(
    <Routes>
      <Route
        path="/directory"
        element={
          <>
            <CompensationFilters />
            <QueryProbe />
          </>
        }
      />
    </Routes>,
    { route },
  );
}

function query() {
  return new URLSearchParams(screen.getByTestId("query").textContent ?? "");
}

beforeEach(() => {
  vi.mocked(api).mockImplementation(async (path) => {
    const catalog = catalogResponse(path);
    if (catalog) return catalog;
    throw new Error(`Unhandled ${path}`);
  });
});

describe("CompensationFilters", () => {
  it("writes a debounced name search and resets the page", async () => {
    const { user } = renderFilters("/directory?page=2");

    await user.type(screen.getByRole("textbox", { name: "Search" }), "ada");

    expect(query().get("search")).toBeNull();
    await vi.waitFor(() => expect(query().get("search")).toBe("ada"));
    expect(query().has("page")).toBe(false);
  });

  it("removes the search param when the box is cleared", async () => {
    const { user } = renderFilters("/directory?search=ada");

    await user.clear(screen.getByRole("textbox", { name: "Search" }));

    await vi.waitFor(() => expect(query().has("search")).toBe(false));
  });

  it("limits titles and levels to the selected department and title", async () => {
    const { user } = renderFilters(
      "/directory?filters[with_department_id]=20&filters[with_job_title_id]=30",
    );

    await user.click(await screen.findByRole("combobox", { name: "Job title" }));
    expect(await screen.findByRole("option", { name: "Engineer" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Accountant" })).not.toBeInTheDocument();
    await user.keyboard("{Escape}");

    await user.click(screen.getByRole("combobox", { name: "Level" }));
    expect(await screen.findByRole("option", { name: "Senior" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Junior" })).not.toBeInTheDocument();
  });

  it("orders levels by rank when no title is selected", async () => {
    const { user } = renderFilters("/directory");

    await user.click(await screen.findByRole("combobox", { name: "Level" }));
    const options = await screen.findAllByRole("option");

    expect(options.map((option) => option.textContent)).toEqual(["Junior", "Senior"]);
  });

  it("clears the title and level when the department changes", async () => {
    const { user } = renderFilters(
      "/directory?filters[with_department_id]=20&filters[with_job_title_id]=30&filters[with_employment_level_id]=40&page=4",
    );

    await user.click(await screen.findByRole("combobox", { name: "Department" }));
    await user.click(await screen.findByRole("option", { name: "Finance" }));

    await vi.waitFor(() => expect(query().get("filters[with_department_id]")).toBe("21"));
    expect(query().get("filters[with_job_title_id]")).toBeNull();
    expect(query().get("filters[with_employment_level_id]")).toBeNull();
    expect(query().has("page")).toBe(false);
  });

  it("clears the level when the job title changes", async () => {
    const { user } = renderFilters(
      "/directory?filters[with_job_title_id]=30&filters[with_employment_level_id]=40",
    );

    await user.click(await screen.findByRole("combobox", { name: "Job title" }));
    await user.click(await screen.findByRole("option", { name: "Accountant" }));

    await vi.waitFor(() => expect(query().get("filters[with_job_title_id]")).toBe("31"));
    expect(query().get("filters[with_employment_level_id]")).toBeNull();
  });

  it("records the salary bounds and status", async () => {
    const { user } = renderFilters("/directory");

    await user.type(screen.getByLabelText("Min salary"), "80000");
    await user.type(screen.getByLabelText("Max salary"), "150000");
    await user.click(screen.getByRole("combobox", { name: "Status" }));
    await user.click(await screen.findByRole("option", { name: "Active" }));

    await vi.waitFor(() => expect(query().get("filters[with_salary_min]")).toBe("80000"));
    expect(query().get("filters[with_salary_max]")).toBe("150000");
    expect(query().get("filters[with_employment_status]")).toBe("active");
  });
});
