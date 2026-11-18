import { employeeName } from "@/features/directory/format";

describe("employeeName", () => {
  it("joins the first and last name", () => {
    expect(employeeName({ first_name: "Ada", last_name: "Lovelace" })).toBe("Ada Lovelace");
  });
});
