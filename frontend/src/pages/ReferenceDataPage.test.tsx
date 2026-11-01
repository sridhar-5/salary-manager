import { screen } from "@testing-library/react";
import { api } from "../api/client";
import { resetAuth } from "../test/authState";
import { catalogResponse, currencies } from "../test/fixtures";
import { renderWithProviders } from "../test/render";
import { ReferenceDataPage } from "./ReferenceDataPage";

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
  resetAuth({ id: 1, email: "hr@example.com", roles: ["super_admin"] });
  vi.mocked(api).mockImplementation(async (path, options) => {
    if (options?.method === "POST" || options?.method === "PATCH" || options?.method === "DELETE") return undefined;
    const catalog = catalogResponse(path);
    if (catalog) return catalog;
    throw new Error(`Unhandled ${path}`);
  });
  vi.spyOn(window, "confirm").mockReturnValue(true);
});

describe("ReferenceDataPage", () => {
  it("blocks everyone except super admins", async () => {
    resetAuth({ id: 2, email: "hr@example.com", roles: ["compensation_admin"] });
    renderWithProviders(<ReferenceDataPage />);

    expect(await screen.findByRole("alert")).toHaveTextContent("Reference data is limited to super admins.");
    expect(screen.queryByRole("tab", { name: "Currencies" })).not.toBeInTheDocument();
  });

  it("lists currencies for a super admin", async () => {
    renderWithProviders(<ReferenceDataPage />);

    expect(await screen.findByRole("cell", { name: currencies[0].code })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: currencies[0].name })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: currencies[1].code })).toBeInTheDocument();
  });

  it("creates a currency", async () => {
    const { user } = renderWithProviders(<ReferenceDataPage />);
    expect(await screen.findByRole("cell", { name: "USD" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Add" }));
    await user.type(await screen.findByLabelText("Code"), "EUR");
    await user.type(screen.getByLabelText("Name"), "Euro");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByText("Currencies saved")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/currencies", {
      method: "POST",
      body: { currency: { code: "EUR", name: "Euro" } },
    });
  });

  it("updates a currency", async () => {
    const { user } = renderWithProviders(<ReferenceDataPage />);
    expect(await screen.findByRole("cell", { name: "USD" })).toBeInTheDocument();

    await user.click(screen.getAllByRole("button", { name: "Edit" })[0]);
    const name = await screen.findByRole("textbox", { name: "Name" });
    await user.clear(name);
    await user.type(name, "United States Dollar");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByText("Currencies saved")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/currencies/1", {
      method: "PATCH",
      body: { currency: { code: "USD", name: "United States Dollar" } },
    });
  });

  it("deletes a currency after confirmation", async () => {
    const { user } = renderWithProviders(<ReferenceDataPage />);
    expect(await screen.findByRole("cell", { name: "USD" })).toBeInTheDocument();

    await user.click(screen.getAllByRole("button", { name: "Delete" })[0]);

    expect(window.confirm).toHaveBeenCalledWith("Delete this record?");
    expect(api).toHaveBeenCalledWith("/api/v1/currencies/1", { method: "DELETE" });
    expect(await screen.findByText("Deleted")).toBeInTheDocument();
  });

  it("does not delete when confirmation is declined", async () => {
    vi.mocked(window.confirm).mockReturnValue(false);
    const { user } = renderWithProviders(<ReferenceDataPage />);
    expect(await screen.findByRole("cell", { name: "USD" })).toBeInTheDocument();
    vi.mocked(api).mockClear();

    await user.click(screen.getAllByRole("button", { name: "Delete" })[0]);

    expect(window.confirm).toHaveBeenCalledWith("Delete this record?");
    expect(api).not.toHaveBeenCalled();
  });
});
