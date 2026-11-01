import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type {
  Country,
  Currency,
  Department,
  EmploymentLevel,
  JobTitle,
  JobTitleLevel,
} from "../api/types";

export function useCatalogs() {
  const currencies = useQuery({
    queryKey: ["currencies"],
    queryFn: () => api<{ currencies: Currency[] }>("/api/v1/currencies"),
  });
  const countries = useQuery({
    queryKey: ["countries"],
    queryFn: () => api<{ countries: Country[] }>("/api/v1/countries"),
  });
  const departments = useQuery({
    queryKey: ["departments"],
    queryFn: () => api<{ departments: Department[] }>("/api/v1/departments"),
  });
  const jobTitles = useQuery({
    queryKey: ["job-titles"],
    queryFn: () => api<{ job_titles: JobTitle[] }>("/api/v1/job_titles"),
  });
  const levels = useQuery({
    queryKey: ["employment-levels"],
    queryFn: () => api<{ employment_levels: EmploymentLevel[] }>("/api/v1/employment_levels"),
  });
  const links = useQuery({
    queryKey: ["job-title-levels"],
    queryFn: () => api<{ job_title_levels: JobTitleLevel[] }>("/api/v1/job_title_levels"),
  });

  const queries = [currencies, countries, departments, jobTitles, levels, links];

  return {
    loading: queries.some((query) => query.isLoading),
    error: queries.find((query) => query.error)?.error,
    currencies: currencies.data?.currencies ?? [],
    countries: countries.data?.countries ?? [],
    departments: departments.data?.departments ?? [],
    jobTitles: jobTitles.data?.job_titles ?? [],
    levels: levels.data?.employment_levels ?? [],
    links: links.data?.job_title_levels ?? [],
  };
}

export function analyticsSearch(params: URLSearchParams) {
  const next = new URLSearchParams(params);
  next.delete("page");
  next.delete("limit");
  const value = next.toString();
  return value ? `?${value}` : "";
}
