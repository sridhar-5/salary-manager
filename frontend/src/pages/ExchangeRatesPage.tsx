import { Button, Group, Modal, Select, Stack, Table, Text, TextInput, Title } from "@mantine/core";
import { useForm } from "@mantine/form";
import { useDisclosure } from "@mantine/hooks";
import { notifications } from "@mantine/notifications";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api, errorMessage, fieldErrors } from "../api/client";
import type { ExchangeRate } from "../api/types";
import { canManageOperations } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { formatDate } from "../components/format";
import { QueryState } from "../components/QueryState";
import { useCatalogs } from "../hooks/useCatalogs";

type RateForm = {
  id?: number;
  base_currency_id: string;
  quote_currency_id: string;
  rate: string;
  effective_date: string;
};

const emptyRate: RateForm = {
  base_currency_id: "",
  quote_currency_id: "",
  rate: "",
  effective_date: "",
};

export function ExchangeRatesPage() {
  const { admin } = useAuth();
  const catalogs = useCatalogs();
  const canWrite = canManageOperations(admin?.roles ?? []);
  const [opened, { open, close }] = useDisclosure(false);
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: ["exchange-rates"],
    queryFn: () => api<{ exchange_rates: ExchangeRate[] }>("/api/v1/exchange_rates"),
  });
  const form = useForm<RateForm>({
    initialValues: emptyRate,
    validate: {
      base_currency_id: (value) => (value ? null : "Choose a base currency"),
      quote_currency_id: (value, values) => {
        if (!value) return "Choose a quote currency";
        if (value === values.base_currency_id) return "Quote currency must differ from the base currency";
        return null;
      },
      rate: (value) => (Number(value) > 0 ? null : "Enter a rate greater than zero"),
      effective_date: (value) => (value ? null : "Choose an effective date"),
    },
  });

  const save = useMutation({
    mutationFn: (values: RateForm) => {
      const payload = {
        exchange_rate: {
          base_currency_id: Number(values.base_currency_id),
          quote_currency_id: Number(values.quote_currency_id),
          rate: values.rate,
          effective_date: values.effective_date,
        },
      };
      if (values.id) return api(`/api/v1/exchange_rates/${values.id}`, { method: "PATCH", body: payload });
      return api("/api/v1/exchange_rates", { method: "POST", body: payload });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["exchange-rates"] });
      queryClient.invalidateQueries({ queryKey: ["summary"] });
      queryClient.invalidateQueries({ queryKey: ["employees"] });
      notifications.show({ message: "Exchange rate saved" });
      close();
    },
    onError: (error) => {
      const errors = fieldErrors(error);
      if (Object.keys(errors).length > 0) form.setErrors(errors);
      else notifications.show({ color: "red", message: errorMessage(error) });
    },
  });

  function code(id: number) {
    return catalogs.currencies.find((currency) => currency.id === id)?.code ?? String(id);
  }

  const currencyOptions = catalogs.currencies.map((currency) => ({
    value: String(currency.id),
    label: `${currency.code} · ${currency.name}`,
  }));

  return (
    <Stack>
      <Group justify="space-between">
        <div>
          <Title order={2}>Exchange rates</Title>
          <Text c="dimmed">One unit of the base currency, priced in the quote currency.</Text>
        </div>
        {canWrite && (
          <Button
            onClick={() => {
              form.setValues(emptyRate);
              open();
            }}
          >
            Add rate
          </Button>
        )}
      </Group>
      <QueryState
        loading={query.isLoading || catalogs.loading}
        error={query.error ?? catalogs.error}
        empty={query.data?.exchange_rates.length === 0}
        emptyLabel="No exchange rates yet."
      >
        <Table>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Base</Table.Th>
              <Table.Th>Quote</Table.Th>
              <Table.Th>Rate</Table.Th>
              <Table.Th>Effective date</Table.Th>
              {canWrite && <Table.Th />}
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {query.data?.exchange_rates.map((rate) => (
              <Table.Tr key={rate.id}>
                <Table.Td>{code(rate.base_currency_id)}</Table.Td>
                <Table.Td>{code(rate.quote_currency_id)}</Table.Td>
                <Table.Td>{rate.rate}</Table.Td>
                <Table.Td>{formatDate(rate.effective_date)}</Table.Td>
                {canWrite && (
                  <Table.Td>
                    <Button
                      size="xs"
                      variant="subtle"
                      onClick={() => {
                        form.setValues({
                          id: rate.id,
                          base_currency_id: String(rate.base_currency_id),
                          quote_currency_id: String(rate.quote_currency_id),
                          rate: rate.rate,
                          effective_date: rate.effective_date.slice(0, 10),
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
      </QueryState>
      <Modal opened={opened} onClose={close} title={form.values.id ? "Edit exchange rate" : "Add exchange rate"}>
        <form onSubmit={form.onSubmit((values) => save.mutate(values))}>
          <Stack>
            <Select label="Base currency" data={currencyOptions} {...form.getInputProps("base_currency_id")} />
            <Select label="Quote currency" data={currencyOptions} {...form.getInputProps("quote_currency_id")} />
            <TextInput label="Rate" description="How many quote units equal one base unit." {...form.getInputProps("rate")} />
            <TextInput label="Effective date" type="date" {...form.getInputProps("effective_date")} />
            <Button type="submit" loading={save.isPending}>
              Save
            </Button>
          </Stack>
        </form>
      </Modal>
    </Stack>
  );
}
