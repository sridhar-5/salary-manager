import { Button, Group, Modal, Select, Stack, Table, Text, TextInput, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { useDisclosure } from "@mantine/hooks";
import { notifications } from "@mantine/notifications";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api, errorMessage, fieldErrors } from "../api/client";
import type { SalaryBand } from "../api/types";
import { canManageOperations } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { formatDate, formatMoney } from "../components/format";
import { QueryState } from "../components/QueryState";
import { useCatalogs } from "../hooks/useCatalogs";

type BandForm = {
  id?: number;
  country_id: string;
  department_id: string;
  job_title_id: string;
  employment_level_id: string;
  currency_id: string;
  min_salary: string;
  max_salary: string;
  effective_from: string;
  effective_to: string;
};

const emptyBand: BandForm = {
  country_id: "",
  department_id: "",
  job_title_id: "",
  employment_level_id: "",
  currency_id: "",
  min_salary: "",
  max_salary: "",
  effective_from: "",
  effective_to: "",
};

export function SalaryBandsPage() {
  const { admin } = useAuth();
  const catalogs = useCatalogs();
  const canWrite = canManageOperations(admin?.roles ?? []);
  const [opened, { open, close }] = useDisclosure(false);
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: ["salary-bands"],
    queryFn: () => api<{ salary_bands: SalaryBand[] }>("/api/v1/salary_bands"),
  });
  const form = useForm<BandForm>({ initialValues: emptyBand });

  const save = useMutation({
    mutationFn: (values: BandForm) => {
      const payload = {
        salary_band: {
          country_id: Number(values.country_id),
          department_id: Number(values.department_id),
          job_title_id: Number(values.job_title_id),
          employment_level_id: Number(values.employment_level_id),
          currency_id: Number(values.currency_id),
          min_salary: values.min_salary,
          max_salary: values.max_salary,
          effective_from: values.effective_from,
          effective_to: values.effective_to || null,
        },
      };
      if (values.id) {
        return api(`/api/v1/salary_bands/${values.id}`, { method: "PATCH", body: payload });
      }
      return api("/api/v1/salary_bands", { method: "POST", body: payload });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["salary-bands"] });
      notifications.show({ message: "Salary band saved" });
      close();
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
  const levels = catalogs.levels.filter((level) => !form.values.job_title_id || levelIds.has(level.id));

  function labelCountry(id: number) {
    return catalogs.countries.find((country) => country.id === id)?.name ?? String(id);
  }
  function labelDepartment(id: number) {
    return catalogs.departments.find((department) => department.id === id)?.name ?? String(id);
  }
  function labelTitle(id: number) {
    return catalogs.jobTitles.find((title) => title.id === id)?.title ?? String(id);
  }
  function labelLevel(id: number) {
    return catalogs.levels.find((level) => level.id === id)?.name ?? String(id);
  }
  function labelCurrency(id: number) {
    return catalogs.currencies.find((currency) => currency.id === id)?.code ?? "";
  }

  return (
    <Stack>
      <Group justify="space-between">
        <div>
          <Title order={2}>Salary bands</Title>
          <Text c="dimmed">Acceptable pay ranges for a country, title, and level.</Text>
        </div>
        {canWrite && (
          <Button
            onClick={() => {
              form.setValues(emptyBand);
              open();
            }}
          >
            Add band
          </Button>
        )}
      </Group>
      <QueryState
        loading={query.isLoading || catalogs.loading}
        error={query.error ?? catalogs.error}
        empty={query.data?.salary_bands.length === 0}
        emptyLabel="No salary bands yet."
      >
        <Table.ScrollContainer minWidth={900}>
          <Table striped>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Country</Table.Th>
                <Table.Th>Department</Table.Th>
                <Table.Th>Title</Table.Th>
                <Table.Th>Level</Table.Th>
                <Table.Th>Range</Table.Th>
                <Table.Th>Effective</Table.Th>
                {canWrite && <Table.Th />}
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {query.data?.salary_bands.map((band) => (
                <Table.Tr key={band.id}>
                  <Table.Td>{labelCountry(band.country_id)}</Table.Td>
                  <Table.Td>{labelDepartment(band.department_id)}</Table.Td>
                  <Table.Td>{labelTitle(band.job_title_id)}</Table.Td>
                  <Table.Td>{labelLevel(band.employment_level_id)}</Table.Td>
                  <Table.Td>
                    {formatMoney(band.min_salary, labelCurrency(band.currency_id))} –{" "}
                    {formatMoney(band.max_salary, labelCurrency(band.currency_id))}
                  </Table.Td>
                  <Table.Td>
                    {formatDate(band.effective_from)} – {band.effective_to ? formatDate(band.effective_to) : "open"}
                  </Table.Td>
                  {canWrite && (
                    <Table.Td>
                      <Button
                        variant="subtle"
                        size="xs"
                        onClick={() => {
                          form.setValues({
                            id: band.id,
                            country_id: String(band.country_id),
                            department_id: String(band.department_id),
                            job_title_id: String(band.job_title_id),
                            employment_level_id: String(band.employment_level_id),
                            currency_id: String(band.currency_id),
                            min_salary: band.min_salary,
                            max_salary: band.max_salary,
                            effective_from: band.effective_from.slice(0, 10),
                            effective_to: band.effective_to?.slice(0, 10) ?? "",
                          });
                          open();
                        }}
                      >
                        Edit
                      </Button>
                    </Table.Td>
                  )}
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
      </QueryState>
      <Modal opened={opened} onClose={close} title={form.values.id ? "Edit salary band" : "Add salary band"}>
        <form onSubmit={form.onSubmit((values) => save.mutate(values))}>
          <Stack>
            <Select
              label="Country"
              data={catalogs.countries.map((country) => ({ value: String(country.id), label: country.name }))}
              {...form.getInputProps("country_id")}
              onChange={(value) => {
                form.setFieldValue("country_id", value ?? "");
                const country = catalogs.countries.find((item) => String(item.id) === value);
                if (country) form.setFieldValue("currency_id", String(country.currency_id));
              }}
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
            <Select
              label="Currency"
              data={catalogs.currencies.map((currency) => ({
                value: String(currency.id),
                label: currency.code,
              }))}
              {...form.getInputProps("currency_id")}
            />
            <Group grow>
              <TextInput label="Minimum" {...form.getInputProps("min_salary")} />
              <TextInput label="Maximum" {...form.getInputProps("max_salary")} />
            </Group>
            <Group grow>
              <TextInput label="Effective from" type="date" {...form.getInputProps("effective_from")} />
              <TextInput label="Effective to" type="date" {...form.getInputProps("effective_to")} />
            </Group>
            <Button type="submit" loading={save.isPending}>
              Save
            </Button>
          </Stack>
        </form>
      </Modal>
    </Stack>
  );
}
