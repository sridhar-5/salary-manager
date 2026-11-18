import { formatMoney } from "@/shared/format/format";

export function usdAmount(annualSalary: string, usdRate: string | null) {
  if (usdRate == null) return null;
  const salary = Number(annualSalary);
  const rate = Number(usdRate);
  if (!Number.isFinite(salary) || !Number.isFinite(rate) || rate === 0) return null;
  return salary / rate;
}

export function usdSalary(
  compensation: { annual_salary: string; usd_rate: string | null } | null | undefined,
) {
  if (!compensation) return "—";
  const amount = usdAmount(compensation.annual_salary, compensation.usd_rate);
  if (amount == null) return "No rate";
  return formatMoney(amount, "USD");
}

export function employeeName(employee: { first_name: string; last_name: string }) {
  return `${employee.first_name} ${employee.last_name}`;
}
