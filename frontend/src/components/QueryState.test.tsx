import { screen } from "@testing-library/react";
import { renderWithProviders } from "../test/render";
import { QueryState } from "./QueryState";

describe("QueryState", () => {
  it("shows a loader and hides the content while loading", () => {
    renderWithProviders(
      <QueryState loading error={null}>
        <p>Ready</p>
      </QueryState>,
    );

    expect(document.querySelector(".mantine-Loader-root")).toBeInTheDocument();
    expect(screen.queryByText("Ready")).not.toBeInTheDocument();
  });

  it("prefers the loader when a request is still in flight", () => {
    renderWithProviders(
      <QueryState loading error={new Error("Network down")}>
        <p>Ready</p>
      </QueryState>,
    );

    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    expect(document.querySelector(".mantine-Loader-root")).toBeInTheDocument();
  });

  it("shows the error message", () => {
    renderWithProviders(
      <QueryState loading={false} error={new Error("Network down")}>
        <p>Ready</p>
      </QueryState>,
    );

    expect(screen.getByRole("alert")).toHaveTextContent("Could not load data");
    expect(screen.getByRole("alert")).toHaveTextContent("Network down");
    expect(screen.queryByText("Ready")).not.toBeInTheDocument();
  });

  it("shows the empty state", () => {
    renderWithProviders(
      <QueryState loading={false} error={null} empty emptyLabel="No employees match these filters.">
        <p>Ready</p>
      </QueryState>,
    );

    expect(screen.getByText("No employees match these filters.")).toBeInTheDocument();
    expect(screen.queryByText("Ready")).not.toBeInTheDocument();
  });

  it("renders the content when the query succeeded", () => {
    renderWithProviders(
      <QueryState loading={false} error={null}>
        <p>Ready</p>
      </QueryState>,
    );

    expect(screen.getByText("Ready")).toBeInTheDocument();
  });
});
