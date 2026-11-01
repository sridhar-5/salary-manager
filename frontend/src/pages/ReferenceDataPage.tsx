import { Alert, Button, Group, Modal, Select, Stack, Table, Tabs, Text, Textarea, TextInput, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { useDisclosure } from "@mantine/hooks";
import { notifications } from "@mantine/notifications";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useState, type ReactNode } from "react";
import { api, errorMessage, fieldErrors } from "../api/client";
import { canManageReference } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { QueryState } from "../components/QueryState";
import { useCatalogs } from "../hooks/useCatalogs";

type Field = {
  name: string;
  label: string;
  kind: "text" | "number" | "textarea" | "select";
  options?: { value: string; label: string }[];
  numeric?: boolean;
};

type Column = {
  key: string;
  label: string;
  render?: (row: Record<string, unknown>) => ReactNode;
};

export function ReferenceDataPage() {
  const { admin } = useAuth();
  const catalogs = useCatalogs();
  if (!canManageReference(admin?.roles ?? [])) {
    return <Alert color="red">Reference data is limited to super admins.</Alert>;
  }

  const departmentOptions = catalogs.departments.map((department) => ({
    value: String(department.id),
    label: department.name,
  }));
  const currencyOptions = catalogs.currencies.map((currency) => ({
    value: String(currency.id),
    label: `${currency.code} · ${currency.name}`,
  }));
  const titleOptions = catalogs.jobTitles.map((title) => ({ value: String(title.id), label: title.title }));
  const levelOptions = catalogs.levels.map((level) => ({ value: String(level.id), label: level.name }));

  return (
    <Stack>
      <div>
        <Title order={2}>Reference data</Title>
        <Text c="dimmed">Countries, org structure, and the levels that apply to each job title.</Text>
      </div>
      <Tabs defaultValue="currencies">
        <Tabs.List>
          <Tabs.Tab value="currencies">Currencies</Tabs.Tab>
          <Tabs.Tab value="countries">Countries</Tabs.Tab>
          <Tabs.Tab value="departments">Departments</Tabs.Tab>
          <Tabs.Tab value="titles">Job titles</Tabs.Tab>
          <Tabs.Tab value="levels">Levels</Tabs.Tab>
          <Tabs.Tab value="links">Title levels</Tabs.Tab>
        </Tabs.List>
        <Tabs.Panel value="currencies" pt="md">
          <CatalogPanel
            title="Currencies"
            path="/api/v1/currencies"
            collection="currencies"
            singular="currency"
            queryKey="currencies"
            fields={[
              { name: "code", label: "Code", kind: "text" },
              { name: "name", label: "Name", kind: "text" },
            ]}
            columns={[
              { key: "code", label: "Code" },
              { key: "name", label: "Name" },
            ]}
          />
        </Tabs.Panel>
        <Tabs.Panel value="countries" pt="md">
          <CatalogPanel
            title="Countries"
            path="/api/v1/countries"
            collection="countries"
            singular="country"
            queryKey="countries"
            fields={[
              { name: "name", label: "Name", kind: "text" },
              { name: "iso_code", label: "ISO code", kind: "text" },
              { name: "currency_id", label: "Currency", kind: "select", numeric: true, options: currencyOptions },
            ]}
            columns={[
              { key: "name", label: "Name" },
              { key: "iso_code", label: "ISO" },
              {
                key: "currency_id",
                label: "Currency",
                render: (row) => catalogs.currencies.find((currency) => currency.id === row.currency_id)?.code ?? "—",
              },
            ]}
          />
        </Tabs.Panel>
        <Tabs.Panel value="departments" pt="md">
          <CatalogPanel
            title="Departments"
            path="/api/v1/departments"
            collection="departments"
            singular="department"
            queryKey="departments"
            fields={[
              { name: "name", label: "Name", kind: "text" },
              { name: "description", label: "Description", kind: "textarea" },
            ]}
            columns={[
              { key: "name", label: "Name" },
              { key: "description", label: "Description" },
            ]}
          />
        </Tabs.Panel>
        <Tabs.Panel value="titles" pt="md">
          <CatalogPanel
            title="Job titles"
            path="/api/v1/job_titles"
            collection="job_titles"
            singular="job_title"
            queryKey="job-titles"
            fields={[
              { name: "title", label: "Title", kind: "text" },
              { name: "department_id", label: "Department", kind: "select", numeric: true, options: departmentOptions },
              { name: "description", label: "Description", kind: "textarea" },
            ]}
            columns={[
              { key: "title", label: "Title" },
              {
                key: "department_id",
                label: "Department",
                render: (row) =>
                  catalogs.departments.find((department) => department.id === row.department_id)?.name ?? "—",
              },
            ]}
          />
        </Tabs.Panel>
        <Tabs.Panel value="levels" pt="md">
          <CatalogPanel
            title="Employment levels"
            path="/api/v1/employment_levels"
            collection="employment_levels"
            singular="employment_level"
            queryKey="employment-levels"
            fields={[
              { name: "name", label: "Name", kind: "text" },
              { name: "rank", label: "Rank", kind: "number", numeric: true },
            ]}
            columns={[
              { key: "name", label: "Name" },
              { key: "rank", label: "Rank" },
            ]}
          />
        </Tabs.Panel>
        <Tabs.Panel value="links" pt="md">
          <CatalogPanel
            title="Job title levels"
            path="/api/v1/job_title_levels"
            collection="job_title_levels"
            singular="job_title_level"
            queryKey="job-title-levels"
            fields={[
              { name: "job_title_id", label: "Job title", kind: "select", numeric: true, options: titleOptions },
              { name: "employment_level_id", label: "Level", kind: "select", numeric: true, options: levelOptions },
            ]}
            columns={[
              {
                key: "job_title_id",
                label: "Job title",
                render: (row) => catalogs.jobTitles.find((title) => title.id === row.job_title_id)?.title ?? "—",
              },
              {
                key: "employment_level_id",
                label: "Level",
                render: (row) => catalogs.levels.find((level) => level.id === row.employment_level_id)?.name ?? "—",
              },
            ]}
          />
        </Tabs.Panel>
      </Tabs>
    </Stack>
  );
}

function CatalogPanel({
  title,
  path,
  collection,
  singular,
  queryKey,
  fields,
  columns,
}: {
  title: string;
  path: string;
  collection: string;
  singular: string;
  queryKey: string;
  fields: Field[];
  columns: Column[];
}) {
  const queryClient = useQueryClient();
  const [opened, { open, close }] = useDisclosure(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const query = useQuery({
    queryKey: [queryKey],
    queryFn: () => api<Record<string, Record<string, unknown>[]>>(path),
  });
  const rows = query.data?.[collection] ?? [];
  const form = useForm<Record<string, string>>({
    initialValues: Object.fromEntries(fields.map((field) => [field.name, ""])),
  });

  const save = useMutation({
    mutationFn: (values: Record<string, string>) => {
      const payload: Record<string, unknown> = {};
      for (const field of fields) {
        const raw = values[field.name] ?? "";
        if (raw === "") continue;
        payload[field.name] = field.numeric ? Number(raw) : raw;
      }
      const body = { [singular]: payload };
      if (editingId) return api(`${path}/${editingId}`, { method: "PATCH", body });
      return api(path, { method: "POST", body });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [queryKey] });
      notifications.show({ message: `${title} saved` });
      close();
    },
    onError: (error) => {
      const errors = fieldErrors(error);
      if (Object.keys(errors).length > 0) form.setErrors(errors);
      else notifications.show({ color: "red", message: errorMessage(error) });
    },
  });

  const remove = useMutation({
    mutationFn: (id: number) => api(`${path}/${id}`, { method: "DELETE" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [queryKey] });
      notifications.show({ message: "Deleted" });
    },
    onError: (error) => notifications.show({ color: "red", message: errorMessage(error) }),
  });

  function startCreate() {
    setEditingId(null);
    form.setValues(Object.fromEntries(fields.map((field) => [field.name, ""])));
    open();
  }

  function startEdit(row: Record<string, unknown>) {
    setEditingId(Number(row.id));
    form.setValues(
      Object.fromEntries(fields.map((field) => [field.name, row[field.name] == null ? "" : String(row[field.name])])),
    );
    open();
  }

  return (
    <Stack>
      <Group justify="space-between">
        <Title order={4}>{title}</Title>
        <Button onClick={startCreate}>Add</Button>
      </Group>
      <QueryState loading={query.isLoading} error={query.error} empty={rows.length === 0} emptyLabel={`No ${title.toLowerCase()} yet.`}>
        <Table>
          <Table.Thead>
            <Table.Tr>
              {columns.map((column) => (
                <Table.Th key={column.key}>{column.label}</Table.Th>
              ))}
              <Table.Th />
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {rows.map((row) => (
              <Table.Tr key={String(row.id)}>
                {columns.map((column) => (
                  <Table.Td key={column.key}>
                    {column.render ? column.render(row) : String(row[column.key] ?? "—")}
                  </Table.Td>
                ))}
                <Table.Td>
                  <Group gap="xs">
                    <Button size="xs" variant="subtle" onClick={() => startEdit(row)}>
                      Edit
                    </Button>
                    <Button
                      size="xs"
                      variant="subtle"
                      color="red"
                      onClick={() => {
                        if (window.confirm("Delete this record?")) remove.mutate(Number(row.id));
                      }}
                    >
                      Delete
                    </Button>
                  </Group>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      </QueryState>
      <Modal opened={opened} onClose={close} title={editingId ? `Edit ${singular.replaceAll("_", " ")}` : `Add ${singular.replaceAll("_", " ")}`}>
        <form onSubmit={form.onSubmit((values) => save.mutate(values))}>
          <Stack>
            {fields.map((field) => {
              if (field.kind === "select") {
                return <Select key={field.name} label={field.label} data={field.options ?? []} {...form.getInputProps(field.name)} />;
              }
              if (field.kind === "textarea") {
                return <Textarea key={field.name} label={field.label} {...form.getInputProps(field.name)} />;
              }
              return <TextInput key={field.name} label={field.label} {...form.getInputProps(field.name)} />;
            })}
            <Button type="submit" loading={save.isPending}>
              Save
            </Button>
          </Stack>
        </form>
      </Modal>
    </Stack>
  );
}
