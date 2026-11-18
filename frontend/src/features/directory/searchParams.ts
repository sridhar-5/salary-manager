export function analyticsSearch(params: URLSearchParams) {
  const next = new URLSearchParams(params);
  next.delete("page");
  next.delete("limit");
  const value = next.toString();
  return value ? `?${value}` : "";
}
