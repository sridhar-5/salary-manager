import { canManageOperations, canManageReference } from "./roles";

describe("canManageOperations", () => {
  it("allows compensation admins and super admins", () => {
    expect(canManageOperations(["compensation_admin"])).toBe(true);
    expect(canManageOperations(["super_admin"])).toBe(true);
    expect(canManageOperations(["viewer", "compensation_admin"])).toBe(true);
  });

  it("rejects everyone else", () => {
    expect(canManageOperations([])).toBe(false);
    expect(canManageOperations(["viewer"])).toBe(false);
  });
});

describe("canManageReference", () => {
  it("allows only super admins", () => {
    expect(canManageReference(["super_admin"])).toBe(true);
    expect(canManageReference(["compensation_admin"])).toBe(false);
    expect(canManageReference(["super_admin", "compensation_admin"])).toBe(true);
    expect(canManageReference([])).toBe(false);
  });
});
