import type {
  CompensationRecord,
  Country,
  Currency,
  Department,
  Employee,
  EmploymentLevel,
  ExchangeRate,
  JobTitle,
  JobTitleLevel,
  Payslip,
  SalaryBand,
} from "../api/types";

export const currencies: Currency[] = [
  { id: 1, code: "USD", name: "US Dollar" },
  { id: 2, code: "INR", name: "Indian Rupee" },
];

export const countries: Country[] = [
  { id: 10, name: "India", iso_code: "IN", currency_id: 2 },
  { id: 11, name: "United States", iso_code: "US", currency_id: 1 },
];

export const departments: Department[] = [
  { id: 20, name: "Engineering", description: null },
  { id: 21, name: "Finance", description: null },
];

export const jobTitles: JobTitle[] = [
  { id: 30, title: "Engineer", description: null, department_id: 20 },
  { id: 31, title: "Accountant", description: null, department_id: 21 },
];

export const levels: EmploymentLevel[] = [
  { id: 41, name: "Junior", rank: 1 },
  { id: 40, name: "Senior", rank: 2 },
];

export const links: JobTitleLevel[] = [
  { id: 1, job_title_id: 30, employment_level_id: 40 },
  { id: 2, job_title_id: 31, employment_level_id: 41 },
];

export function catalogResponse(path: string) {
  if (path.startsWith("/api/v1/currencies")) return { currencies };
  if (path.startsWith("/api/v1/countries")) return { countries };
  if (path.startsWith("/api/v1/departments")) return { departments };
  if (path.startsWith("/api/v1/job_titles")) return { job_titles: jobTitles };
  if (path.startsWith("/api/v1/employment_levels")) return { employment_levels: levels };
  if (path.startsWith("/api/v1/job_title_levels")) return { job_title_levels: links };
  return undefined;
}

export function employee(overrides: Partial<Employee> = {}): Employee {
  return {
    id: 5,
    employee_number: "E-0005",
    first_name: "Ada",
    last_name: "Lovelace",
    email: "ada@example.com",
    employment_status: "active",
    hire_date: "2020-01-15",
    termination_date: null,
    country_id: 10,
    department_id: 20,
    job_title_id: 30,
    employment_level_id: 40,
    manager_id: null,
    reporting_currency: { id: 1, code: "USD", name: "US Dollar" },
    country: { id: 10, name: "India", iso_code: "IN" },
    department: { id: 20, name: "Engineering" },
    job_title: { id: 30, title: "Engineer" },
    employment_level: { id: 40, name: "Senior", rank: 2 },
    current_compensation: {
      id: 1,
      annual_salary: "120000",
      currency: { id: 2, code: "INR" },
      effective_from: "2024-01-01",
      effective_to: null,
      reporting_amount: "1500",
    },
    payslips: [],
    manager: null,
    ...overrides,
  };
}

export function payslip(overrides: Partial<Payslip> = {}): Payslip {
  return {
    id: 7,
    employee_id: 5,
    payslip_number: "PS-7",
    period_start: "2024-01-01",
    period_end: "2024-01-31",
    pay_date: "2024-02-01",
    gross_pay: "10000.50",
    deductions: "100.25",
    net_pay: "9900.25",
    status: "paid",
    currency: { id: 2, code: "INR", name: "Indian Rupee" },
    created_at: "2024-02-01T00:00:00Z",
    updated_at: "2024-02-01T00:00:00Z",
    ...overrides,
  };
}

export function compensationRecord(overrides: Partial<CompensationRecord> = {}): CompensationRecord {
  return {
    id: 9,
    employee_id: 5,
    annual_salary: "100000",
    effective_from: "2024-01-01",
    effective_to: "2024-12-31",
    created_at: "2024-01-01T00:00:00Z",
    updated_at: "2024-06-01T12:00:00Z",
    currency: { id: 1, code: "USD", name: "US Dollar" },
    created_by: { id: 1, email: "hr@example.com" },
    audit_events: [
      {
        event: "update",
        at: "2024-06-01T12:00:00Z",
        whodunnit_email: null,
        changes: { effective_to: [null, "2024-12-31"] },
      },
    ],
    ...overrides,
  };
}

export function salaryBand(overrides: Partial<SalaryBand> = {}): SalaryBand {
  return {
    id: 3,
    country_id: 10,
    department_id: 20,
    job_title_id: 30,
    employment_level_id: 40,
    currency_id: 2,
    min_salary: "80000",
    max_salary: "140000",
    effective_from: "2024-01-01",
    effective_to: null,
    ...overrides,
  };
}

export function exchangeRate(overrides: Partial<ExchangeRate> = {}): ExchangeRate {
  return {
    id: 4,
    base_currency_id: 1,
    quote_currency_id: 2,
    rate: "83.2",
    effective_date: "2024-01-01",
    ...overrides,
  };
}
