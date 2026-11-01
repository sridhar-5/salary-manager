export type Currency = { id: number; code: string; name: string };

export type Country = {
  id: number;
  name: string;
  iso_code: string;
  currency_id: number;
};

export type Department = {
  id: number;
  name: string;
  description: string | null;
};

export type JobTitle = {
  id: number;
  title: string;
  description: string | null;
  department_id: number;
};

export type EmploymentLevel = { id: number; name: string; rank: number };

export type JobTitleLevel = {
  id: number;
  job_title_id: number;
  employment_level_id: number;
};

export type AdminUser = { id: number; email: string; roles: string[] };

export type CurrentCompensation = {
  id: number;
  annual_salary: string;
  currency: { id: number; code: string };
  effective_from: string;
  effective_to: string | null;
  reporting_amount: string | null;
};

export type Employee = {
  id: number;
  employee_number: string;
  first_name: string;
  last_name: string;
  email: string;
  employment_status: "active" | "terminated";
  hire_date: string;
  termination_date: string | null;
  country_id: number;
  department_id: number;
  job_title_id: number;
  employment_level_id: number;
  manager_id: number | null;
  reporting_currency: Currency | null;
  country: { id: number; name: string; iso_code: string };
  department: { id: number; name: string };
  job_title: { id: number; title: string };
  employment_level: { id: number; name: string; rank: number };
  current_compensation: CurrentCompensation | null;
  manager?: {
    id: number;
    first_name: string;
    last_name: string;
    employee_number: string;
  } | null;
};

export type DirectoryResponse = {
  employees: Employee[];
  meta: {
    page: number;
    per_page: number;
    total_count: number;
    total_pages: number;
    reporting_currency: Currency | null;
    unconverted_count: number;
  };
};

export type AuditEvent = {
  event: string;
  at: string;
  whodunnit_email: string | null;
  changes: Record<string, unknown> | null;
};

export type CompensationRecord = {
  id: number;
  employee_id: number;
  annual_salary: string;
  effective_from: string;
  effective_to: string | null;
  created_at: string;
  updated_at: string;
  currency: { id: number; code: string; name: string };
  created_by: { id: number; email: string };
  audit_events: AuditEvent[];
};

export type SalaryBand = {
  id: number;
  country_id: number;
  department_id: number;
  job_title_id: number;
  employment_level_id: number;
  currency_id: number;
  min_salary: string;
  max_salary: string;
  effective_from: string;
  effective_to: string | null;
};

export type ExchangeRate = {
  id: number;
  base_currency_id: number;
  quote_currency_id: number;
  rate: string;
  effective_date: string;
};
