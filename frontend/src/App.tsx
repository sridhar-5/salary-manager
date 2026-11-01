import { Center, Loader } from "@mantine/core";
import { Navigate, Outlet, Route, Routes } from "react-router";
import { useAuth } from "./auth/AuthContext";
import { AppLayout } from "./components/AppLayout";
import { AccountPage } from "./pages/AccountPage";
import { DirectoryPage } from "./pages/DirectoryPage";
import { EmployeeFormPage } from "./pages/EmployeeFormPage";
import { EmployeePage } from "./pages/EmployeePage";
import { ExchangeRatesPage } from "./pages/ExchangeRatesPage";
import { LoginPage } from "./pages/LoginPage";
import { ReferenceDataPage } from "./pages/ReferenceDataPage";
import { SalaryBandsPage } from "./pages/SalaryBandsPage";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<RequireAuth />}>
        <Route element={<AppLayout />}>
          <Route index element={<Navigate to="/directory" replace />} />
          <Route path="/directory" element={<DirectoryPage />} />
          <Route path="/employees/new" element={<EmployeeFormPage />} />
          <Route path="/employees/:id" element={<EmployeePage />} />
          <Route path="/employees/:id/edit" element={<EmployeeFormPage />} />
          <Route path="/salary-bands" element={<SalaryBandsPage />} />
          <Route path="/exchange-rates" element={<ExchangeRatesPage />} />
          <Route path="/reference" element={<ReferenceDataPage />} />
          <Route path="/account" element={<AccountPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/directory" replace />} />
    </Routes>
  );
}

function RequireAuth() {
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
