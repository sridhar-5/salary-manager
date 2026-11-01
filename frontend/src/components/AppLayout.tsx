import { AppShell, Burger, Button, Group, Menu, NavLink, Text } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { Link, Outlet, useLocation, useNavigate, useSearchParams } from "react-router";
import { canManageReference } from "../auth/roles";
import { useAuth } from "../auth/AuthContext";
import { analyticsSearch } from "../hooks/useCatalogs";

const LINKS = [
  { to: "/directory", label: "Directory" },
  { to: "/salary-bands", label: "Salary bands" },
  { to: "/exchange-rates", label: "Exchange rates" },
];

export function AppLayout() {
  const { admin, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const sharedFilters = analyticsSearch(params);
  const [opened, { toggle, close }] = useDisclosure();
  const links = canManageReference(admin?.roles ?? [])
    ? [...LINKS, { to: "/reference", label: "Reference data" }]
    : LINKS;

  async function onLogout() {
    await logout();
    navigate("/login");
  }

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{ width: 230, breakpoint: "sm", collapsed: { mobile: !opened } }}
      padding="md"
    >
      <AppShell.Header>
        <Group h="100%" px="md" justify="space-between">
          <Group>
            <Burger opened={opened} onClick={toggle} hiddenFrom="sm" size="sm" aria-label="Open navigation" />
            <Text fw={700}>Salary Manager</Text>
          </Group>
          <Menu position="bottom-end">
            <Menu.Target>
              <Button variant="subtle">{admin?.email}</Button>
            </Menu.Target>
            <Menu.Dropdown>
              <Menu.Label>{admin?.roles.join(", ")}</Menu.Label>
              <Menu.Item component={Link} to="/account">
                Account
              </Menu.Item>
              <Menu.Item onClick={onLogout}>Log out</Menu.Item>
            </Menu.Dropdown>
          </Menu>
        </Group>
      </AppShell.Header>
      <AppShell.Navbar p="sm">
        {links.map((link) => (
          <NavLink
            key={link.to}
            component={Link}
            to={sharesFilters(link.to) ? `${link.to}${sharedFilters}` : link.to}
            label={link.label}
            active={isActive(location.pathname, link.to)}
            onClick={close}
          />
        ))}
      </AppShell.Navbar>
      <AppShell.Main>
        <Outlet />
      </AppShell.Main>
    </AppShell>
  );
}

function sharesFilters(to: string) {
  return to === "/directory";
}

function isActive(pathname: string, to: string) {
  if (to === "/directory") return pathname === "/directory" || pathname.startsWith("/employees");
  return pathname === to || pathname.startsWith(`${to}/`);
}
