import { screen } from "@testing-library/react";
import { api } from "../api/client";
import { resetAuth } from "../test/authState";
import { catalogResponse, exchangeRate } from "../test/fixtures";
import { chooseOption, renderWithProviders } from "../test/render";
import { ExchangeRatesPage } from "./ExchangeRatesPage";

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
    if (path.startsWith("/api/v1/exchange_rates")) return { exchange_rates: [exchangeRate()] };
    throw new Error(`Unhandled ${path}`);
  });
});

describe("ExchangeRatesPage", () => {
  it("lists rates and hides editing from viewers", async () => {
    resetAuth({ id: 2, email: "viewer@example.com", roles: ["viewer"] });
    renderWithProviders(<ExchangeRatesPage />);

    expect(await screen.findByRole("cell", { name: "USD" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "INR" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "83.2" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "2024-01-01" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Add rate" })).not.toBeInTheDocument();
  });

  it("validates a new rate before saving", async () => {
    const { user } = renderWithProviders(<ExchangeRatesPage />);
    await screen.findByRole("cell", { name: "USD" });

    await user.click(screen.getByRole("button", { name: "Add rate" }));
    await user.click(await screen.findByRole("button", { name: "Save" }));

    expect(screen.getByText("Choose a base currency")).toBeInTheDocument();
    expect(screen.getByText("Choose a quote currency")).toBeInTheDocument();
    expect(screen.getByText("Enter a rate greater than zero")).toBeInTheDocument();
    expect(screen.getByText("Choose an effective date")).toBeInTheDocument();

    await chooseOption(user, "Base currency", "USD · US Dollar");
    await chooseOption(user, "Quote currency", "USD · US Dollar");
    await user.type(screen.getByLabelText("Rate"), "1.5");
    await user.type(screen.getByLabelText("Effective date"), "2024-05-01");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(screen.getByText("Quote currency must differ from the base currency")).toBeInTheDocument();
    expect(api).not.toHaveBeenCalledWith("/api/v1/exchange_rates", expect.objectContaining({ method: "POST" }));
  });

  it("saves a rate between two currencies", async () => {
    const { user } = renderWithProviders(<ExchangeRatesPage />);
    await screen.findByRole("cell", { name: "USD" });

    await user.click(screen.getByRole("button", { name: "Add rate" }));
    await chooseOption(user, "Base currency", "USD · US Dollar");
    await chooseOption(user, "Quote currency", "INR · Indian Rupee");
    await user.type(screen.getByLabelText("Rate"), "83.2");
    await user.type(screen.getByLabelText("Effective date"), "2024-05-01");
    await user.click(screen.getByRole("button", { name: "Save" }));

    expect(await screen.findByText("Exchange rate saved")).toBeInTheDocument();
    expect(api).toHaveBeenCalledWith("/api/v1/exchange_rates", {
      method: "POST",
      body: {
        exchange_rate: {
          base_currency_id: 1,
          quote_currency_id: 2,
          rate: "83.2",
          effective_date: "2024-05-01",
        },
      },
    });
  });

  it("shows an empty state and a load error", async () => {
    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      if (path.startsWith("/api/v1/exchange_rates")) return { exchange_rates: [] };
      throw new Error(`Unhandled ${path}`);
    });
    const { unmount } = renderWithProviders(<ExchangeRatesPage />);
    expect(await screen.findByText("No exchange rates yet.")).toBeInTheDocument();
    unmount();

    vi.mocked(api).mockImplementation(async (path) => {
      const catalog = catalogResponse(path);
      if (catalog) return catalog;
      throw new Error("Rates unavailable");
    });
    renderWithProviders(<ExchangeRatesPage />);
    expect(await screen.findByRole("alert")).toHaveTextContent("Rates unavailable");
  });
});
