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
