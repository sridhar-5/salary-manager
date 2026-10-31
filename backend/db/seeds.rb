# Idempotent mock data for development. Safe to re-run with `bin/rails db:seed`.

usd = Currency.find_or_create_by!(code: "USD") { |currency| currency.name = "US Dollar" }
inr = Currency.find_or_create_by!(code: "INR") { |currency| currency.name = "Indian Rupee" }
gbp = Currency.find_or_create_by!(code: "GBP") { |currency| currency.name = "Pound Sterling" }

Country.find_or_create_by!(iso_code: "US") do |country|
  country.name = "United States"
  country.currency = usd
end
Country.find_or_create_by!(iso_code: "IN") do |country|
  country.name = "India"
  country.currency = inr
end
Country.find_or_create_by!(iso_code: "GB") do |country|
  country.name = "United Kingdom"
  country.currency = gbp
end

[
  [ "Engineering", "Builds and maintains product software." ],
  [ "People", "Owns hiring, performance, and employee experience." ],
  [ "Finance", "Manages payroll, planning, and compensation." ]
].each do |name, description|
  Department.find_or_create_by!(name:) { |department| department.description = description }
end

job_titles = [
  [ "Software Engineer", "Designs and ships product features." ],
  [ "Engineering Manager", "Leads an engineering team and delivery." ],
  [ "Product Manager", "Sets product direction and priorities." ],
  [ "People Partner", "Partners with teams on hiring and performance." ],
  [ "Finance Analyst", "Supports compensation and financial planning." ]
].to_h do |title, description|
  [ title, JobTitle.find_or_create_by!(title:) { |job_title| job_title.description = description } ]
end

employment_levels = [
  [ "Junior", 1 ],
  [ "Mid", 2 ],
  [ "Senior", 3 ],
  [ "Staff", 4 ],
  [ "Principal", 5 ]
].to_h do |name, rank|
  [ name, EmploymentLevel.find_or_create_by!(name:) { |level| level.rank = rank } ]
end

{
  "Software Engineer" => %w[Junior Mid Senior Staff],
  "Engineering Manager" => %w[Senior Staff Principal],
  "Product Manager" => %w[Mid Senior Staff],
  "People Partner" => %w[Mid Senior],
  "Finance Analyst" => %w[Junior Mid Senior]
}.each do |title, level_names|
  job_title = job_titles.fetch(title)

  level_names.each do |level_name|
    JobTitleLevel.find_or_create_by!(
      job_title:,
      employment_level: employment_levels.fetch(level_name)
    )
  end
end
