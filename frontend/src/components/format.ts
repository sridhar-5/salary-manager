export function formatMoney(
  amount: string | number | null | undefined,
  currency?: string | null,
  fractionDigits = 0,
) {
  if (amount == null || amount === "") return "—";
  const value = Number(amount);
  if (!Number.isFinite(value)) return "—";
  if (!currency) {
    return value.toLocaleString(undefined, {
      minimumFractionDigits: fractionDigits,
      maximumFractionDigits: fractionDigits,
    });
  }

  try {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency,
      minimumFractionDigits: fractionDigits,
      maximumFractionDigits: fractionDigits,
    }).format(value);
  } catch {
    return `${value.toLocaleString(undefined, {
      minimumFractionDigits: fractionDigits,
      maximumFractionDigits: fractionDigits,
    })} ${currency}`;
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
