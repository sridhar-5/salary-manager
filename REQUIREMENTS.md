# ACME Salary Manager — Product Requirements

A web app for ACME's HR Manager to manage compensation for 10,000 employees across countries. It replaces spreadsheet workflows with a searchable source of truth for how the organization pays its employees.

The live app is [https://melodic-semolina-9d5ec3.netlify.app/](https://melodic-semolina-9d5ec3.netlify.app/).

Sign in with `admin@example.com` / `password`. This user has the **super admin** role and can see every screen in the app.

## Target User

**Primary user**: HR Manager responsible for reviewing employee compensation, maintaining salary records, and analyzing compensation across the organization.

## Scope and Features

Each item below is marked with what the current app does.

### 1. Employee Directory and Search

- **Implemented.** The directory lists the seeded employees in a paginated, searchable table.
- **Implemented.** Search by employee name or employee number. Filter by country, department, job title, level, employment status, and salary range. A reporting currency can be chosen so local pay and converted pay stay distinct.
- **Implemented.** An employee profile shows organization, location, currency, current salary, compensation history, and payslips.

### 2. Salary Management

- **Implemented.** HR can create an employee and update their record. A new salary is stored as its own compensation record and closes the previous open record. The end date of an existing record can be edited.
- **Implemented for seeded history.** Each employee profile lists monthly payslips (number, period, pay date, gross, deductions, net, and status). The seed creates the last six months of payslips. Choosing a month and generating a new payslip from the app is not built.
- **Implemented.** Salaries stay in the employee country's currency. The directory and profile also show the amount in the selected reporting currency, or say when no exchange rate exists.
- **Implemented.** Compensation records keep effective dates. The profile shows an audit trail of changes: the event, previous and new values, timestamp, and the user responsible.
- **Implemented.** Salary and employee forms reject incomplete or invalid input. The API returns field errors, and the database enforces constraints.

### 3. Security and Reliability

- **Implemented.** HR signs in with email and password. The session is a bearer token. Sensitive pages stay behind that login.
- **Implemented.** Authorization is enforced in the API with roles, not only in the UI.
  - Super admin can manage every resource, including reference data.
  - Compensation admin can manage employees, compensation, payslips, salary bands, and exchange rates.
  - Viewer can read those records and cannot change them.
- **Implemented.** Models validate input, the database uses constraints, and the API returns clear errors for bad requests and forbidden actions.
- **Implemented.** `bin/rails db:seed` loads demo data for 10,000 employees. Directory search and filters are paginated.

### Also implemented

These screens support the compensation workflow:

- **Salary bands.** Acceptable pay ranges for a country, department, title, and level, with effective dates.
- **Exchange rates.** Rates used to convert local salary into the reporting currency.
- **Reference data.** Super admins can maintain currencies, countries, departments, job titles, levels, and which levels apply to each title.
- **Account.** A signed-in user can change their password.

## Deliberately Out of Scope

- **Spreadsheet/CSV import.** Data is loaded by the seed script.
- **Payroll processing.** No country-specific tax calculations, statutory deductions, or bank transfers.
- **Recruitment and performance management.** No hiring pipeline, reviews, promotion workflow, or employee self-service.
- **Complex global compensation rules.** No automated tax, benefits, or statutory payroll calculations per country.
- **Compensation insights and dashboard.** No out-of-band alerts, no average or median comparisons across departments, countries, or levels, and no chart that answers which group is paid the most. Salary bands are stored and editable, and they are not used to flag employees outside a band.
