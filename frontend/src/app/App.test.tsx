import { screen } from "@testing-library/react";
import App from "@/app/App";
import { AUTH_TOKEN_KEY } from "@/shared/api/client";
import { emptyResponse, jsonResponse } from "@/shared/test/http";
import { renderWithProviders } from "@/shared/test/render";

vi.mock("@/features/auth/LoginPage", () => ({
  LoginPage: () => <h1>Login page</h1>,
}));

vi.mock("@/features/directory/DirectoryPage", () => ({
  DirectoryPage: () => <h1>Directory page</h1>,
}));

vi.mock("@/features/directory/EmployeeFormPage", () => ({
  EmployeeFormPage: () => <h1>Employee form</h1>,
}));

vi.mock("@/features/directory/EmployeePage", () => ({
  EmployeePage: () => <h1>Employee page</h1>,
}));

vi.mock("@/features/salary-bands/SalaryBandsPage", () => ({
  SalaryBandsPage: () => <h1>Salary bands page</h1>,
}));

vi.mock("@/features/exchange-rates/ExchangeRatesPage", () => ({
  ExchangeRatesPage: () => <h1>Exchange rates page</h1>,
}));

vi.mock("@/features/reference-data/ReferenceDataPage", () => ({
  ReferenceDataPage: () => <h1>Reference page</h1>,
}));

vi.mock("@/features/auth/AccountPage", () => ({
  AccountPage: () => <h1>Account page</h1>,
}));

const admin = { id: 1, email: "hr@example.com", roles: ["compensation_admin"] };

function renderApp(route: string) {
  return renderWithProviders(<App />, { route });
}

beforeEach(() => {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (_input: RequestInfo | URL, init?: RequestInit) => {
      if (init?.method === "DELETE") return emptyResponse();
      return jsonResponse({ admin_user: admin });
    }),
  );
});

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("App", () => {
  it("sends anonymous visitors to the login page", async () => {
    renderApp("/directory");

    expect(await screen.findByRole("heading", { name: "Login page" })).toBeInTheDocument();
  });

  it("sends unknown paths to login when nobody is signed in", async () => {
    renderApp("/missing");

    expect(await screen.findByRole("heading", { name: "Login page" })).toBeInTheDocument();
  });

  it("waits for the stored session before showing the directory", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    let resolveSession: (response: Response) => void = () => undefined;
    vi.mocked(fetch).mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveSession = resolve;
        }),
    );

    renderApp("/directory");

    expect(document.querySelector(".mantine-Loader-root")).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Directory page" })).not.toBeInTheDocument();

    resolveSession(jsonResponse({ admin_user: admin }));

    expect(await screen.findByRole("heading", { name: "Directory page" })).toBeInTheDocument();
  });

  it("opens employee records inside the directory section", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    renderApp("/employees/5?search=ada&page=2");

    expect(await screen.findByRole("heading", { name: "Employee page" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Directory" })).toHaveAttribute("href", "/directory?search=ada");
    expect(screen.getByRole("link", { name: "Directory" })).toHaveAttribute("data-active", "true");
    expect(screen.queryByRole("link", { name: "Reference data" })).not.toBeInTheDocument();
  });

  it("shows reference data to a super admin", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    vi.mocked(fetch).mockResolvedValue(
      jsonResponse({ admin_user: { ...admin, roles: ["super_admin"] } }),
    );
    renderApp("/reference");

    expect(await screen.findByRole("heading", { name: "Reference page" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Reference data" })).toHaveAttribute("data-active", "true");
  });

  it("logs out from the account menu", async () => {
    sessionStorage.setItem(AUTH_TOKEN_KEY, "secret");
    const { user } = renderApp("/account");
    expect(await screen.findByRole("heading", { name: "Account page" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "hr@example.com" }));
    await user.click(await screen.findByRole("menuitem", { name: "Log out" }));

    expect(await screen.findByRole("heading", { name: "Login page" })).toBeInTheDocument();
    expect(sessionStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
  });
});
