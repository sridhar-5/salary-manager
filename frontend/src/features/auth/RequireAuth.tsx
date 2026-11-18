import { Center, Loader } from "@mantine/core";
import { Navigate, Outlet } from "react-router";
import { useAuth } from "@/features/auth/AuthContext";

export function RequireAuth() {
  const { admin, loading } = useAuth();
  if (loading) {
    return (
      <Center mih="100vh">
        <Loader />
      </Center>
    );
  }
  if (!admin) return <Navigate to="/login" replace />;
  return <Outlet />;
}
