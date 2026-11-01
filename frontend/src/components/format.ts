export function formatMoney(amount: string | number | null | undefined, currency?: string | null) {
  if (amount == null || amount === "") return "—";
  const value = Number(amount);
  if (!Number.isFinite(value)) return "—";
  if (!currency) {
    return value.toLocaleString(undefined, { maximumFractionDigits: 0 });
  }

  try {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(value);
  } catch {
    return `${value.toLocaleString(undefined, { maximumFractionDigits: 0 })} ${currency}`;
  }
}

export function formatDate(value: string | null | undefined) {
  if (!value) return "—";
  return value.slice(0, 10);
}

export function formatDateTime(value: string | null | undefined) {
  if (!value) return "—";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString();
}

export function employeeName(employee: { first_name: string; last_name: string }) {
  return `${employee.first_name} ${employee.last_name}`;
}
