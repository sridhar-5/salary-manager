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
