import { formatDate, formatDateTime, formatMoney, employeeName } from "./format";

describe("formatMoney", () => {
  it("returns a dash for missing or non-numeric amounts", () => {
    expect(formatMoney(null)).toBe("—");
    expect(formatMoney(undefined)).toBe("—");
    expect(formatMoney("")).toBe("—");
    expect(formatMoney("not-a-number")).toBe("—");
  });

  it("formats a plain amount with the requested fraction digits", () => {
    expect(formatMoney(1200)).toBe(
      (1200).toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 }),
    );
    expect(formatMoney("1200.4", null, 2)).toBe(
      (1200.4).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    );
  });

  it("formats a known currency with Intl", () => {
    expect(formatMoney(1500, "USD", 2)).toBe(
      new Intl.NumberFormat(undefined, {
        style: "currency",
        currency: "USD",
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(1500),
    );
  });

  it("falls back to the currency code when the code is not a real currency", () => {
    const formatted = (10).toLocaleString(undefined, {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    });
    expect(formatMoney(10, "nope")).toBe(`${formatted} nope`);
  });
});

describe("formatDate", () => {
  it("returns a dash when the value is missing", () => {
    expect(formatDate(null)).toBe("—");
    expect(formatDate(undefined)).toBe("—");
    expect(formatDate("")).toBe("—");
  });

  it("keeps the calendar date from an ISO timestamp", () => {
    expect(formatDate("2024-01-15T10:00:00Z")).toBe("2024-01-15");
  });
});

describe("formatDateTime", () => {
  it("returns a dash when the value is missing", () => {
    expect(formatDateTime(null)).toBe("—");
    expect(formatDateTime("")).toBe("—");
  });

  it("returns the original text when it is not a date", () => {
    expect(formatDateTime("not-a-date")).toBe("not-a-date");
  });

  it("formats a valid timestamp in the local timezone", () => {
    const value = "2024-06-01T12:00:00Z";
    expect(formatDateTime(value)).toBe(new Date(value).toLocaleString());
  });
});

describe("employeeName", () => {
  it("joins the first and last name", () => {
    expect(employeeName({ first_name: "Ada", last_name: "Lovelace" })).toBe("Ada Lovelace");
  });
});
