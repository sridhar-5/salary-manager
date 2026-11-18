export function canManageOperations(roles: string[]) {
  return roles.includes("super_admin") || roles.includes("compensation_admin");
}

export function canManageReference(roles: string[]) {
  return roles.includes("super_admin");
}
