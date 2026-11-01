import { Group, NumberInput, Select, TextInput } from "@mantine/core";
import { useEffect, useState } from "react";
import { useSearchParams } from "react-router";
import { useCatalogs } from "../hooks/useCatalogs";

export function CompensationFilters() {
  const [params, setParams] = useSearchParams();
  const catalogs = useCatalogs();
  const q = params.get("search") ?? "";
  const [draft, setDraft] = useState<string | null>(null);
  const search = draft ?? q;
  const departmentId = params.get("filters[with_department_id]") ?? "";
  const jobTitleId = params.get("filters[with_job_title_id]") ?? "";

  useEffect(() => {
    if (draft === null || draft === q) return undefined;
    const timer = window.setTimeout(() => {
      const next = new URLSearchParams(params);
      if (draft) next.set("search", draft);
      else next.delete("search");
      next.delete("page");
      setParams(next, { replace: true });
      setDraft(null);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [draft, q, params, setParams]);

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
        value={search}
        onChange={(event) => setDraft(event.currentTarget.value)}
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
      <Select
        label="Reporting currency"
        placeholder="Default (USD)"
        clearable
        data={catalogs.currencies.map((currency) => ({
          value: String(currency.id),
          label: `${currency.code} · ${currency.name}`,
        }))}
        value={params.get("filters[with_reporting_currency_id]")}
        onChange={(value) => update("filters[with_reporting_currency_id]", value ?? "")}
      />
      <NumberInput
        label="Min salary"
        placeholder="Reporting amount"
        min={0}
        hideControls
        value={params.get("filters[with_salary_min]") ?? ""}
        onChange={(value) => update("filters[with_salary_min]", value === "" ? "" : String(value))}
      />
      <NumberInput
        label="Max salary"
        placeholder="Reporting amount"
        min={0}
        hideControls
        value={params.get("filters[with_salary_max]") ?? ""}
        onChange={(value) => update("filters[with_salary_max]", value === "" ? "" : String(value))}
      />
    </Group>
  );
}
