import { Button, Group, Select, Stack, TextInput, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { notifications } from "@mantine/notifications";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";
import { Link, useNavigate, useParams } from "react-router";
import { api, errorMessage, fieldErrors } from "../api/client";
import type { Employee } from "../api/types";
import { QueryState } from "../components/QueryState";
import { useCatalogs } from "../hooks/useCatalogs";

type EmployeeFormValues = {
  employee_number: string;
  first_name: string;
  last_name: string;
  email: string;
  country_id: string;
  department_id: string;
  job_title_id: string;
  employment_level_id: string;
  manager_id: string;
  employment_status: string;
  hire_date: string;
  termination_date: string;
};

const emptyValues: EmployeeFormValues = {
  employee_number: "",
  first_name: "",
  last_name: "",
  email: "",
  country_id: "",
  department_id: "",
  job_title_id: "",
  employment_level_id: "",
  manager_id: "",
  employment_status: "active",
  hire_date: "",
  termination_date: "",
};

export function EmployeeFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const catalogs = useCatalogs();
  const existing = useQuery({
    queryKey: ["employee", id],
    enabled: Boolean(id),
    queryFn: () => api<{ employee: Employee }>(`/api/v1/employees/${id}`),
  });
  const form = useForm<EmployeeFormValues>({
    initialValues: emptyValues,
    validate: {
      employee_number: (value) => (value.trim() ? null : "Enter an employee number"),
      first_name: (value) => (value.trim() ? null : "Enter a first name"),
      last_name: (value) => (value.trim() ? null : "Enter a last name"),
      email: (value) => (value.includes("@") ? null : "Enter a valid email"),
      country_id: (value) => (value ? null : "Choose a country"),
      department_id: (value) => (value ? null : "Choose a department"),
      job_title_id: (value) => (value ? null : "Choose a job title"),
      employment_level_id: (value) => (value ? null : "Choose a level"),
      hire_date: (value) => (value ? null : "Choose a hire date"),
      termination_date: (value, values) =>
        values.employment_status === "terminated" && !value ? "Choose a termination date" : null,
    },
  });

  useEffect(() => {
    const employee = existing.data?.employee;
    if (!employee) return;
    form.setValues({
      employee_number: employee.employee_number,
      first_name: employee.first_name,
      last_name: employee.last_name,
      email: employee.email,
      country_id: String(employee.country_id),
      department_id: String(employee.department_id),
      job_title_id: String(employee.job_title_id),
      employment_level_id: String(employee.employment_level_id),
      manager_id: employee.manager_id ? String(employee.manager_id) : "",
      employment_status: employee.employment_status,
      hire_date: employee.hire_date.slice(0, 10),
      termination_date: employee.termination_date?.slice(0, 10) ?? "",
    });
  }, [existing.data]);

  const save = useMutation({
    mutationFn: (values: EmployeeFormValues) => {
      const payload = {
        employee: {
          ...values,
          country_id: Number(values.country_id),
          department_id: Number(values.department_id),
          job_title_id: Number(values.job_title_id),
          employment_level_id: Number(values.employment_level_id),
          manager_id: values.manager_id ? Number(values.manager_id) : null,
          termination_date: values.employment_status === "terminated" ? values.termination_date : null,
        },
      };
      if (id) return api<{ employee: Employee }>(`/api/v1/employees/${id}`, { method: "PATCH", body: payload });
      return api<{ employee: Employee }>("/api/v1/employees", { method: "POST", body: payload });
    },
    onSuccess: (body) => {
      queryClient.invalidateQueries({ queryKey: ["employees"] });
      queryClient.invalidateQueries({ queryKey: ["employee", String(body.employee.id)] });
      notifications.show({ message: id ? "Employee updated" : "Employee created" });
      navigate(`/employees/${body.employee.id}`);
    },
    onError: (error) => {
      const errors = fieldErrors(error);
      if (Object.keys(errors).length > 0) form.setErrors(errors);
      else notifications.show({ color: "red", message: errorMessage(error) });
    },
  });

  const jobTitles = catalogs.jobTitles.filter(
    (title) => !form.values.department_id || String(title.department_id) === form.values.department_id,
  );
  const levelIds = new Set(
    catalogs.links
      .filter((link) => String(link.job_title_id) === form.values.job_title_id)
      .map((link) => link.employment_level_id),
  );
  const levels = catalogs.levels
    .filter((level) => !form.values.job_title_id || levelIds.has(level.id))
    .sort((a, b) => a.rank - b.rank);

  return (
    <QueryState loading={Boolean(id) && existing.isLoading} error={existing.error}>
      <Stack maw={720}>
        <Title order={2}>{id ? "Edit employee" : "Add employee"}</Title>
        <form onSubmit={form.onSubmit((values) => save.mutate(values))}>
          <Stack>
            <Group grow>
              <TextInput label="Employee number" {...form.getInputProps("employee_number")} />
              <TextInput label="Email" {...form.getInputProps("email")} />
            </Group>
            <Group grow>
              <TextInput label="First name" {...form.getInputProps("first_name")} />
              <TextInput label="Last name" {...form.getInputProps("last_name")} />
            </Group>
            <Select
              label="Country"
              data={catalogs.countries.map((country) => ({ value: String(country.id), label: country.name }))}
              {...form.getInputProps("country_id")}
            />
            <Select
              label="Department"
              data={catalogs.departments.map((department) => ({
                value: String(department.id),
                label: department.name,
              }))}
              {...form.getInputProps("department_id")}
              onChange={(value) => {
                form.setFieldValue("department_id", value ?? "");
                form.setFieldValue("job_title_id", "");
                form.setFieldValue("employment_level_id", "");
              }}
            />
            <Select
              label="Job title"
              data={jobTitles.map((title) => ({ value: String(title.id), label: title.title }))}
              {...form.getInputProps("job_title_id")}
              onChange={(value) => {
                form.setFieldValue("job_title_id", value ?? "");
                form.setFieldValue("employment_level_id", "");
              }}
            />
            <Select
              label="Level"
              data={levels.map((level) => ({ value: String(level.id), label: level.name }))}
              {...form.getInputProps("employment_level_id")}
            />
            <Group grow>
              <Select
                label="Status"
                data={[
                  { value: "active", label: "Active" },
                  { value: "terminated", label: "Terminated" },
                ]}
                {...form.getInputProps("employment_status")}
              />
              <TextInput label="Hire date" type="date" {...form.getInputProps("hire_date")} />
            </Group>
            {form.values.employment_status === "terminated" && (
              <TextInput label="Termination date" type="date" {...form.getInputProps("termination_date")} />
            )}
            <TextInput
              label="Manager id"
              description="Optional employee id. Leave blank if this person has no manager."
              {...form.getInputProps("manager_id")}
            />
            <Group>
              <Button type="submit" loading={save.isPending}>
                Save
              </Button>
              <Button component={Link} to={id ? `/employees/${id}` : "/directory"} variant="default">
                Cancel
              </Button>
            </Group>
          </Stack>
        </form>
      </Stack>
    </QueryState>
  );
}
