# ACME Salary Manager — Product Requirements
Building a web-based salary management platform that enables ACME's HR Manager to manage compensation data for 10,000 employees across multiple countries.
The platform replaces spreadsheet-based workflows with a centralized, searchable source of truth and provide actionable insights into how the organization pays its employees.

### Target User

**Primary user**: HR Manager responsible for reviewing employee compensation, maintaining salary records, and analyzing compensation across the organization.

## Scope and Features

### 1. Employee Directory and Search
- Display all 10,000 employees in a searchable, paginated directory.
- Search by employee name or ID; filter by country, department, job title, employment status, and salary range.
- View employee details, including organizational information, location, currency, and compensation history.

### 2. Salary Management
- Create and update employee compensation records.
- Support country-specific currencies and clearly distinguish local salary amounts from converted reporting amounts.
- Record effective dates and maintain an audit trail of salary changes, including previous values, updated values, timestamps, and the user responsible.
- Validate salary inputs and prevent invalid or incomplete updates.

### 3. Compensation Analytics Dashboard
- Show headcount, total annual compensation, average and median salary, and salary distribution.
- Break down compensation by country, department, job title, and employment level.
- Visualize salary distributions and identify potential compensation outliers.
- Allow filters to be applied consistently across dashboard metrics and charts.

### 4. Compensation Insights
- Identify employees whose compensation falls outside configurable salary bands for comparable roles.
- Compare average compensation across departments, countries, and job levels.
- Provide answers to common HR questions, such as which department has the highest median salary or how compensation varies by country.
- Clearly communicate the currency, population, and filters used in each analysis.

### 5. Security and Reliability
- Provide authenticated HR access and protect sensitive compensation information.
- Enforce authorization on the backend, not just in the UI.
- Use database constraints, input validation, and appropriate error handling.
- Support seeded demo data for 10,000 employees and reliable performance for common searches and dashboard queries.

### Deliberately Out of Scope
- **Spreadsheet/CSV import:** The application will be populated through a repeatable seed script, as data ingestion is not a priority for this assignment.
- **Payroll processing and payments:** No payslip generation, tax calculations, deductions, or bank transfers; these require a separate payroll system.
- **Recruitment and performance management:** Hiring pipelines, reviews, promotions workflows, and employee self-service are outside the core compensation use case.
- **Complex global compensation rules:** No automated tax, benefits, or statutory payroll calculations for individual countries.