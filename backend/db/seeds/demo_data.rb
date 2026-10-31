require "faker"

module DemoData
  TARGET = 10_000
  BATCH_SIZE = 1_000
  # Same employee number always resolves to the same person across re-seeds.
  NAME_SEED = 2026_01_01
  NAME_LOCALE_BY_COUNTRY = {
    "US" => :en,
    "GB" => :"en-GB",
    "IN" => :"en-IND"
  }.freeze
  LEVEL_BASE_USD = { 1 => 70_000, 2 => 95_000, 3 => 130_000, 4 => 170_000, 5 => 210_000 }.freeze
  CURRENCY_FACTOR = { "USD" => BigDecimal("1"), "INR" => BigDecimal("83"), "GBP" => BigDecimal("0.78") }.freeze

  def self.seed!(admin)
    seed_exchange_rates
    seed_salary_bands
    seed_employees(admin)
  end

  def self.seed_exchange_rates
    usd = Currency.find_by!(code: "USD")
    inr = Currency.find_by!(code: "INR")
    gbp = Currency.find_by!(code: "GBP")
    effective_date = Date.new(2024, 1, 1)

    [
      [ inr, usd, "0.012" ],
      [ gbp, usd, "1.27" ],
      [ usd, inr, "83.0" ],
      [ usd, gbp, "0.7874" ]
    ].each do |base, quote, rate|
      ExchangeRate.find_or_create_by!(base_currency: base, quote_currency: quote, effective_date:) do |record|
        record.rate = rate
      end
    end
  end

  def self.seed_salary_bands
    slots.each do |slot|
      countries.each do |country|
        typical = annual_salary(slot[:rank], country.currency.code, 15)
        SalaryBand.find_or_create_by!(
          country:,
          department_id: slot[:department_id],
          job_title_id: slot[:job_title_id],
          employment_level_id: slot[:employment_level_id],
          effective_from: Date.new(2024, 1, 1)
        ) do |band|
          band.currency = country.currency
          band.min_salary = (typical * BigDecimal("0.8")).round(4)
          band.max_salary = (typical * BigDecimal("1.25")).round(4)
        end
      end
    end
  end

  def self.seed_employees(admin)
    missing = TARGET - Employee.count
    return if missing <= 0

    taken = Employee.where("employee_number LIKE 'ACME%'").pluck(:employee_number).to_set
    now = Time.current
    rows = []
    sequence = 1

    while rows.size < missing
      serial = sequence
      number = format("ACME%05d", serial)
      sequence += 1
      raise "Ran out of demo employee numbers" if sequence > TARGET + taken.size + 10

      next if taken.include?(number)

      index = rows.size
      country = countries[index % countries.size]
      slot = slots[index % slots.size]
      hire_date = Date.new(2016, 1, 1) + (index % 3200)
      terminated = (index % 20).zero?
      termination_date = terminated ? [ hire_date + 700, Date.current ].min : nil
      if termination_date.present? && termination_date < hire_date
        terminated = false
        termination_date = nil
      end
      first_name, last_name = person_name(serial, country.iso_code)

      rows << {
        employee_number: number,
        first_name:,
        last_name:,
        email: "#{number.downcase}@acme.test",
        country_id: country.id,
        department_id: slot[:department_id],
        job_title_id: slot[:job_title_id],
        employment_level_id: slot[:employment_level_id],
        employment_status: terminated ? "terminated" : "active",
        hire_date:,
        termination_date:,
        created_at: now,
        updated_at: now,
        _currency_id: country.currency_id,
        _currency_code: country.currency.code,
        _rank: slot[:rank]
      }
    end

    inserted = []
    rows.each_slice(BATCH_SIZE) do |batch|
      payload = batch.map { |row| row.except(:_currency_id, :_currency_code, :_rank) }
      result = Employee.insert_all(payload, returning: %w[id employee_number])
      ids = result.to_a.index_by { |record| record["employee_number"] }
      batch.each do |row|
        inserted << row.merge(id: ids.fetch(row[:employee_number])["id"])
      end
    end

    compensation_rows = []
    inserted.each_with_index do |row, index|
      current_from = row[:hire_date] < Date.current - 200 ? Date.current - 180 : row[:hire_date]
      if index % 5 == 0 && row[:hire_date] < current_from
        compensation_rows << compensation_row(
          row,
          admin,
          annual_salary(row[:_rank], row[:_currency_code], index, historical: true),
          row[:hire_date],
          current_from - 1.day,
          now
        )
      end
      compensation_rows << compensation_row(
        row,
        admin,
        annual_salary(row[:_rank], row[:_currency_code], index),
        current_from,
        nil,
        now
      )
    end

    compensation_rows.each_slice(BATCH_SIZE) do |batch|
      CompensationRecord.insert_all(batch)
    end

    Employee.connection.execute(<<~SQL.squish)
      UPDATE employees AS employee
      SET manager_id = manager.id
      FROM employees AS manager
      WHERE employee.employee_number LIKE 'ACME%'
        AND manager.employee_number = 'ACME' || LPAD((((SUBSTRING(employee.employee_number FROM 5)::integer - 1) / 12) * 12 + 1)::text, 5, '0')
        AND employee.id <> manager.id
    SQL
  end

  def self.person_name(serial, country_code)
    previous_random = Faker::Config.random
    previous_locale = Faker::Config.own_locale
    Faker::Config.random = Random.new(NAME_SEED + serial)
    Faker::Config.locale = NAME_LOCALE_BY_COUNTRY.fetch(country_code, :en)
    [ Faker::Name.first_name, Faker::Name.last_name ]
  ensure
    Faker::Config.random = previous_random.is_a?(Random) ? previous_random : nil
    Faker::Config.locale = previous_locale
  end

  def self.compensation_row(employee, admin, salary, effective_from, effective_to, now)
    {
      employee_id: employee[:id],
      annual_salary: salary,
      currency_id: employee[:_currency_id],
      effective_from:,
      effective_to:,
      created_by_id: admin.id,
      created_at: now,
      updated_at: now
    }
  end

  def self.annual_salary(rank, currency_code, index, historical: false)
    base = BigDecimal(LEVEL_BASE_USD.fetch(rank).to_s)
    factor = CURRENCY_FACTOR.fetch(currency_code)
    noise = BigDecimal("0.85") + (BigDecimal(index % 30) * BigDecimal("0.01"))
    amount = base * factor * noise
    amount *= BigDecimal("0.9") if historical
    amount.round(4)
  end

  def self.countries
    @countries ||= Country.where(iso_code: %w[US IN GB]).includes(:currency).order(:iso_code).to_a
  end

  def self.slots
    @slots ||= JobTitleLevel.includes(:employment_level, job_title: :department).map do |link|
      {
        job_title_id: link.job_title_id,
        department_id: link.job_title.department_id,
        employment_level_id: link.employment_level_id,
        rank: link.employment_level.rank
      }
    end
  end
end
