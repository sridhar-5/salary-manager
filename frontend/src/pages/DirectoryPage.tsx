import { Badge, Button, Group, Pagination, Stack, Table, Text, Title } from "@mantine/core";
import { useQuery } from "@tanstack/react-query";
import { Link, useSearchParams } from "react-router";
import { api } from "../api/client";
import type { DirectoryResponse } from "../api/types";
import { canManageOperations } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { CompensationFilters } from "../components/CompensationFilters";
import { employeeName, formatMoney, usdSalary } from "../components/format";
import { QueryState } from "../components/QueryState";

export function DirectoryPage() {
  const { admin } = useAuth();
  const [params, setParams] = useSearchParams();
  const query = useQuery({
    queryKey: ["employees", params.toString()],
    queryFn: () => api<DirectoryResponse>(`/api/v1/employees?${params.toString()}`),
  });
  const meta = query.data?.meta;
  const canWrite = canManageOperations(admin?.roles ?? []);
  const start = meta && meta.total_count > 0 ? (meta.page - 1) * meta.per_page + 1 : 0;
  const end = meta ? Math.min(meta.page * meta.per_page, meta.total_count) : 0;

  return (
    <Stack>
      <Group justify="space-between">
        <div>
          <Title order={2}>Directory</Title>
          <Text c="dimmed">Search employees and compare local pay with USD.</Text>
        </div>
        {canWrite && (
          <Button component={Link} to="/employees/new">
            Add employee
          </Button>
        )}
      </Group>
      <CompensationFilters />
      <QueryState
        loading={query.isLoading}
        error={query.error}
        empty={query.data?.employees.length === 0}
        emptyLabel="No employees match these filters."
      >
        {meta && (
          <Text size="sm" c="dimmed">
            Showing {start.toLocaleString()}–{end.toLocaleString()} of {meta.total_count.toLocaleString()}.
            Local salary stays in the employee’s currency. USD is that salary divided by the USD rate.
          </Text>
        )}
        <Table.ScrollContainer minWidth={980}>
          <Table striped highlightOnHover>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Employee</Table.Th>
                <Table.Th>Department</Table.Th>
                <Table.Th>Title</Table.Th>
                <Table.Th>Level</Table.Th>
                <Table.Th>Country</Table.Th>
                <Table.Th>Status</Table.Th>
                <Table.Th>Local salary</Table.Th>
                <Table.Th>USD salary</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {query.data?.employees.map((employee) => {
                const pay = employee.current_compensation;
                return (
                  <Table.Tr key={employee.id}>
                    <Table.Td>
                      <Text component={Link} to={`/employees/${employee.id}`} fw={600}>
                        {employeeName(employee)}
                      </Text>
                      <Text size="xs" c="dimmed">
                        {employee.employee_number}
                      </Text>
                    </Table.Td>
                    <Table.Td>{employee.department.name}</Table.Td>
                    <Table.Td>{employee.job_title.title}</Table.Td>
                    <Table.Td>{employee.employment_level.name}</Table.Td>
                    <Table.Td>{employee.country.name}</Table.Td>
                    <Table.Td>
                      <Badge color={employee.employment_status === "active" ? "teal" : "gray"} variant="light">
                        {employee.employment_status}
                      </Badge>
                    </Table.Td>
                    <Table.Td>
                      {pay ? formatMoney(pay.annual_salary, pay.currency.code) : "No current salary"}
                    </Table.Td>
                    <Table.Td>{usdSalary(pay)}</Table.Td>
                  </Table.Tr>
                );
              })}
            </Table.Tbody>
          </Table>
        </Table.ScrollContainer>
        {meta && meta.total_pages > 1 && (
          <Pagination
            total={meta.total_pages}
            value={meta.page}
            onChange={(page) => {
              const next = new URLSearchParams(params);
              next.set("page", String(page));
              setParams(next);
            }}
          />
        )}
      </QueryState>
    </Stack>
  );
}
