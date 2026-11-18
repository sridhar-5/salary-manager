import { Navigate, Route, Routes } from "react-router";
import { AppLayout } from "@/app/layout/AppLayout";
import { AccountPage } from "@/features/auth/AccountPage";
import { LoginPage } from "@/features/auth/LoginPage";
import { RequireAuth } from "@/features/auth/RequireAuth";
import { DirectoryPage } from "@/features/directory/DirectoryPage";
import { EmployeeFormPage } from "@/features/directory/EmployeeFormPage";
import { EmployeePage } from "@/features/directory/EmployeePage";
import { ExchangeRatesPage } from "@/features/exchange-rates/ExchangeRatesPage";
import { ReferenceDataPage } from "@/features/reference-data/ReferenceDataPage";
import { SalaryBandsPage } from "@/features/salary-bands/SalaryBandsPage";

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
