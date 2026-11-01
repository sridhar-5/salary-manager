import {
  Accordion,
  Badge,
  Button,
  Group,
  Modal,
  SimpleGrid,
  Stack,
  Table,
  Text,
  TextInput,
  Title,
} from "@mantine/core";
import { useForm } from "@mantine/form";
import { useDisclosure } from "@mantine/hooks";
import { notifications } from "@mantine/notifications";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { Link, useParams, useSearchParams } from "react-router";
import { api, errorMessage, fieldErrors } from "../api/client";
import type { CompensationRecord, Employee, Payslip, PayslipStatus } from "../api/types";
import { canManageOperations } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { employeeName, formatDate, formatDateTime, formatMoney } from "../components/format";
import { QueryState } from "../components/QueryState";
import { analyticsSearch } from "../hooks/useCatalogs";

export function EmployeePage() {
  const { id } = useParams();
  const { admin } = useAuth();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();
  const canWrite = canManageOperations(admin?.roles ?? []);
  const [salaryOpened, { open: openSalary, close: closeSalary }] = useDisclosure(false);
  const [editingRecord, setEditingRecord] = useState<CompensationRecord | null>(null);
  const employeeQuery = useQuery({
    queryKey: ["employee", id, params.get("reporting_currency_id")],
    queryFn: () => api<{ employee: Employee }>(`/api/v1/employees/${id}${analyticsSearch(params)}`),
  });
  const historyQuery = useQuery({
    queryKey: ["compensation", id],
    queryFn: () =>
      api<{ compensation_records: CompensationRecord[] }>(`/api/v1/employees/${id}/compensation_records`),
  });
  const employee = employeeQuery.data?.employee;
  const reportingCode = employee?.reporting_currency?.code;

  function refresh() {
    queryClient.invalidateQueries({ queryKey: ["employee", id] });
    queryClient.invalidateQueries({ queryKey: ["compensation", id] });
    queryClient.invalidateQueries({ queryKey: ["employees"] });
    queryClient.invalidateQueries({ queryKey: ["summary"] });
  }

  return (
    <Stack>
      <QueryState loading={employeeQuery.isLoading} error={employeeQuery.error}>
        {employee && (
          <>
            <Group justify="space-between">
              <div>
                <Title order={2}>{employeeName(employee)}</Title>
                <Text c="dimmed">
                  {employee.employee_number} · {employee.email}
                </Text>
              </div>
              {canWrite && (
                <Button component={Link} to={`/employees/${employee.id}/edit`} variant="default">
                  Edit employee
                </Button>
              )}
            </Group>
            <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }}>
              <Detail label="Department" value={employee.department.name} />
              <Detail label="Job title" value={employee.job_title.title} />
              <Detail label="Level" value={employee.employment_level.name} />
              <Detail label="Country" value={`${employee.country.name} (${employee.country.iso_code})`} />
              <Detail label="Status" value={employee.employment_status} />
              <Detail label="Hire date" value={formatDate(employee.hire_date)} />
              <Detail label="Termination date" value={formatDate(employee.termination_date)} />
              <Detail
                label="Manager"
                value={
                  employee.manager
                    ? `${employeeName(employee.manager)} (${employee.manager.employee_number})`
                    : "—"
                }
              />
              <Detail
                label="Current local salary"
                value={
                  employee.current_compensation
                    ? formatMoney(
                        employee.current_compensation.annual_salary,
                        employee.current_compensation.currency.code,
                      )
                    : "No current salary"
                }
              />
              <Detail
                label={`Current reporting salary${reportingCode ? ` (${reportingCode})` : ""}`}
                value={
                  employee.current_compensation?.reporting_amount
                    ? formatMoney(employee.current_compensation.reporting_amount, reportingCode)
                    : employee.current_compensation
                      ? "No exchange rate"
                      : "—"
                }
              />
            </SimpleGrid>
            <Payslips payslips={employee.payslips} />
          </>
        )}
      </QueryState>

      <Group justify="space-between">
        <Title order={3}>Compensation history</Title>
        {canWrite && (
          <Button onClick={openSalary}>Add salary</Button>
        )}
      </Group>
      <Text c="dimmed" size="sm">
        Salary amounts are kept as new records. A new salary closes the previous open record the day before it starts.
        Only the end date of an existing record can be edited.
      </Text>
      <QueryState
        loading={historyQuery.isLoading}
        error={historyQuery.error}
        empty={historyQuery.data?.compensation_records.length === 0}
        emptyLabel="No compensation records yet."
      >
        <Accordion variant="contained">
          {historyQuery.data?.compensation_records.map((record) => (
            <Accordion.Item key={record.id} value={String(record.id)}>
              <Accordion.Control>
                {formatMoney(record.annual_salary, record.currency.code)} · {formatDate(record.effective_from)} to{" "}
                {record.effective_to ? formatDate(record.effective_to) : "present"} · {record.created_by.email}
              </Accordion.Control>
              <Accordion.Panel>
                <Stack gap="xs">
                  <Text size="sm">Created {formatDateTime(record.created_at)} by {record.created_by.email}.</Text>
                  {record.audit_events.length === 0 ? (
                    <Text size="sm" c="dimmed">No audit events.</Text>
                  ) : (
                    record.audit_events.map((event, index) => (
                      <Text size="sm" key={`${event.at}-${index}`}>
                        {event.event} at {formatDateTime(event.at)} by {event.whodunnit_email ?? "unknown"}.{" "}
                        {describeChanges(event.changes)}
                      </Text>
                    ))
                  )}
                  {canWrite && (
                    <Button variant="light" w="fit-content" onClick={() => setEditingRecord(record)}>
                      Edit end date
                    </Button>
                  )}
                </Stack>
              </Accordion.Panel>
            </Accordion.Item>
          ))}
        </Accordion>
      </QueryState>

      <SalaryModal
        opened={salaryOpened}
        onClose={closeSalary}
        employeeId={id!}
        onSaved={() => {
          closeSalary();
          refresh();
        }}
      />
      <EndDateModal
        record={editingRecord}
        employeeId={id!}
        onClose={() => setEditingRecord(null)}
        onSaved={() => {
          setEditingRecord(null);
          refresh();
        }}
      />
    </Stack>
  );
}

const PAYSLIP_STATUS_COLOR: Record<PayslipStatus, string> = {
  issued: "blue",
  paid: "teal",
  void: "gray",
};

function Payslips({ payslips }: { payslips: Payslip[] }) {
  return (
    <Stack gap="xs">
      <Title order={3}>Payslips</Title>
      <Text c="dimmed" size="sm">
        Monthly statements for this employee, newest first. Amounts are in the employee’s local currency.
      </Text>
      {payslips.length === 0 ? (
        <Text c="dimmed">No payslips yet.</Text>
      ) : (
        <Table.ScrollContainer minWidth={860}>
          <Table striped highlightOnHover>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Payslip</Table.Th>
                <Table.Th>Period</Table.Th>
                <Table.Th>Pay date</Table.Th>
                <Table.Th>Gross</Table.Th>
                <Table.Th>Deductions</Table.Th>
                <Table.Th>Net</Table.Th>
                <Table.Th>Status</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {payslips.map((payslip) => (
                <Table.Tr key={payslip.id}>
                  <Table.Td>{payslip.payslip_number}</Table.Td>
                  <Table.Td>
                    {formatDate(payslip.period_start)} – {formatDate(payslip.period_end)}
                  </Table.Td>
                  <Table.Td>{formatDate(payslip.pay_date)}</Table.Td>
                  <Table.Td>{formatMoney(payslip.gross_pay, payslip.currency.code, 2)}</Table.Td>
                  <Table.Td>{formatMoney(payslip.deductions, payslip.currency.code, 2)}</Table.Td>
                  <Table.Td>{formatMoney(payslip.net_pay, payslip.currency.code, 2)}</Table.Td>
                  <Table.Td>
                    <Badge color={PAYSLIP_STATUS_COLOR[payslip.status]} variant="light">
                      {payslip.status}
                    </Badge>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
      )}
    </Stack>
  );
}

function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <Text size="xs" c="dimmed" tt="uppercase">
        {label}
      </Text>
      <Text>{value}</Text>
    </div>
  );
}

function describeChanges(changes: Record<string, unknown> | null) {
  if (!changes) return "";
  return Object.entries(changes)
    .map(([field, value]) => {
      if (Array.isArray(value)) return `${field}: ${value[0] ?? "empty"} → ${value[1] ?? "empty"}`;
      return `${field}: ${JSON.stringify(value)}`;
    })
    .join(" ");
}

function SalaryModal({
  opened,
  onClose,
  employeeId,
  onSaved,
}: {
  opened: boolean;
  onClose: () => void;
  employeeId: string;
  onSaved: () => void;
}) {
  const form = useForm({
    initialValues: { annual_salary: "", effective_from: "" },
    validate: {
      annual_salary: (value: string) => (Number(value) > 0 ? null : "Enter a salary greater than zero"),
      effective_from: (value: string) => (value ? null : "Choose the date this salary takes effect"),
    },
  });
  const save = useMutation({
    mutationFn: () =>
      api(`/api/v1/employees/${employeeId}/compensation_records`, {
        method: "POST",
        body: {
          compensation_record: {
            annual_salary: form.values.annual_salary,
            effective_from: form.values.effective_from,
          },
        },
      }),
    onSuccess: () => {
      form.reset();
      notifications.show({ message: "Salary recorded" });
      onSaved();
    },
    onError: (error) => {
      const errors = fieldErrors(error);
      if (Object.keys(errors).length > 0) form.setErrors(errors);
      else notifications.show({ color: "red", message: errorMessage(error) });
    },
  });

  return (
    <Modal opened={opened} onClose={onClose} title="Add salary">
      <form onSubmit={form.onSubmit(() => save.mutate())}>
        <Stack>
          <Text size="sm" c="dimmed">
            The amount is stored in the employee’s country currency. The previous open salary ends the day before this
            one starts.
          </Text>
          <TextInput label="Annual salary" inputMode="decimal" {...form.getInputProps("annual_salary")} />
          <TextInput label="Effective from" type="date" {...form.getInputProps("effective_from")} />
          <Button type="submit" loading={save.isPending}>
            Save salary
          </Button>
        </Stack>
      </form>
    </Modal>
  );
}

function EndDateModal({
  record,
  onClose,
  employeeId,
  onSaved,
}: {
  record: CompensationRecord | null;
  onClose: () => void;
  employeeId: string;
  onSaved: () => void;
}) {
  return (
    <Modal opened={record !== null} onClose={onClose} title="Edit end date">
      {record && (
        <EndDateForm key={record.id} record={record} employeeId={employeeId} onSaved={onSaved} />
      )}
    </Modal>
  );
}

function EndDateForm({
  record,
  employeeId,
  onSaved,
}: {
  record: CompensationRecord;
  employeeId: string;
  onSaved: () => void;
}) {
  const form = useForm({
    initialValues: { effective_to: record.effective_to?.slice(0, 10) ?? "" },
  });
  const save = useMutation({
    mutationFn: () =>
      api(`/api/v1/employees/${employeeId}/compensation_records/${record.id}`, {
        method: "PATCH",
        body: {
          compensation_record: {
            effective_to: form.values.effective_to || null,
          },
        },
      }),
    onSuccess: () => {
      notifications.show({ message: "End date updated" });
      onSaved();
    },
    onError: (error) => notifications.show({ color: "red", message: errorMessage(error) }),
  });

  return (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        save.mutate();
      }}
    >
      <Stack>
        <TextInput
          label="Effective to"
          type="date"
          description="Leave blank to keep the salary open."
          {...form.getInputProps("effective_to")}
        />
        <Button type="submit" loading={save.isPending}>
          Save end date
        </Button>
      </Stack>
    </form>
  );
}
