import { Group, Select, TextInput } from "@mantine/core";
import { useEffect, useRef, useState } from "react";
import { useSearchParams } from "react-router";
import { useCatalogs } from "@/features/reference-data/useCatalogs";

const FILTER_DEBOUNCE_MS = 300;

function useDebouncedQueryParam(key: string, normalize: (value: string) => string | null | undefined) {
  const [params, setParams] = useSearchParams();
  const committed = params.get(key) ?? "";
  const [draft, setDraft] = useState<string | null>(null);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => {
    return () => window.clearTimeout(timer.current);
  }, []);

  function onChange(value: string) {
    setDraft(value);
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => {
      const nextValue = normalize(value);
      if (nextValue === undefined) return;
      setParams(
        (current) => {
          const next = new URLSearchParams(current);
          if (nextValue) next.set(key, nextValue);
          else next.delete(key);
          next.delete("page");
          return next;
        },
        { replace: true },
      );
      setDraft(null);
    }, FILTER_DEBOUNCE_MS);
  }

  return { value: draft ?? committed, onChange };
}

function normalizeSearch(value: string) {
  return value ? value : null;
}

function normalizeMinSalary(value: string): string | null | undefined {
  const trimmed = value.trim();
  if (!trimmed) return null;
  const match = trimmed.match(/^(\d+)(?:\.(\d{1,4}))?$/);
  if (!match) return undefined;
  return match[2] ? `${match[1]}.${match[2]}` : match[1];
}

function acceptMinSalaryDraft(value: string) {
  return value === "" || /^\d*\.?\d{0,4}$/.test(value);
}

export function CompensationFilters() {
  const [params, setParams] = useSearchParams();
  const catalogs = useCatalogs();
  const search = useDebouncedQueryParam("search", normalizeSearch);
  const minSalary = useDebouncedQueryParam("filters[min_salary]", normalizeMinSalary);
  const departmentId = params.get("filters[with_department_id]") ?? "";
  const jobTitleId = params.get("filters[with_job_title_id]") ?? "";

  function update(key: string, value: string) {
    const next = new URLSearchParams(params);
    if (value) next.set(key, value);
    else next.delete(key);
    next.delete("page");
    if (key === "filters[with_department_id]") {
      next.delete("filters[with_job_title_id]");
      next.delete("filters[with_employment_level_id]");
    }
    if (key === "filters[with_job_title_id]") next.delete("filters[with_employment_level_id]");
    setParams(next, { replace: true });
  }

  const jobTitles = catalogs.jobTitles.filter(
    (title) => !departmentId || String(title.department_id) === departmentId,
  );
  const levelIds = new Set(
    catalogs.links
      .filter((link) => !jobTitleId || String(link.job_title_id) === jobTitleId)
      .map((link) => link.employment_level_id),
  );
  const levels = catalogs.levels
    .filter((level) => !jobTitleId || levelIds.has(level.id))
    .sort((a, b) => a.rank - b.rank);

  return (
    <Group align="end" grow preventGrowOverflow={false}>
      <TextInput
        label="Search"
        placeholder="Name or employee number"
        value={search.value}
        onChange={(event) => search.onChange(event.currentTarget.value)}
      />
      <TextInput
        label="Min salary"
        placeholder="Any amount"
        inputMode="decimal"
        value={minSalary.value}
        onChange={(event) => {
          const value = event.currentTarget.value;
          if (!acceptMinSalaryDraft(value)) return;
          minSalary.onChange(value);
        }}
      />
      <Select
        label="Country"
        placeholder="All countries"
        clearable
        data={catalogs.countries.map((country) => ({
          value: String(country.id),
          label: country.name,
        }))}
        value={params.get("filters[with_country_id]")}
        onChange={(value) => update("filters[with_country_id]", value ?? "")}
      />
      <Select
        label="Department"
        placeholder="All departments"
        clearable
        data={catalogs.departments.map((department) => ({
          value: String(department.id),
          label: department.name,
        }))}
        value={params.get("filters[with_department_id]")}
        onChange={(value) => update("filters[with_department_id]", value ?? "")}
      />
      <Select
        label="Job title"
        placeholder="All titles"
        clearable
        data={jobTitles.map((title) => ({ value: String(title.id), label: title.title }))}
        value={params.get("filters[with_job_title_id]")}
        onChange={(value) => update("filters[with_job_title_id]", value ?? "")}
      />
      <Select
        label="Level"
        placeholder="All levels"
        clearable
        data={levels.map((level) => ({ value: String(level.id), label: level.name }))}
        value={params.get("filters[with_employment_level_id]")}
        onChange={(value) => update("filters[with_employment_level_id]", value ?? "")}
      />
      <Select
        label="Status"
        placeholder="Any status"
        clearable
        data={[
          { value: "active", label: "Active" },
          { value: "terminated", label: "Terminated" },
        ]}
        value={params.get("filters[with_employment_status]")}
        onChange={(value) => update("filters[with_employment_status]", value ?? "")}
      />
    </Group>
  );
}
