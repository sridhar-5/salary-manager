class CompensationSummary
  DISTRIBUTION_BUCKETS = CompensationSummarySerializer::DISTRIBUTION_BUCKETS

  def initialize(query)
    @query = query
  end

  def call
    filtered = query.all_records.unscope(:order)
    paid = filtered.where("reporting_amount IS NOT NULL")
    total, average, median, min_amount, max_amount = totals_for(paid)

    levels = EmploymentLevel.pluck(:id, :name, :rank)

    CompensationSummarySerializer.new(
      reporting_currency: query.reporting_currency,
      filters: query.summary_filters,
      population: filtered.count,
      unconverted_count: query.unconverted_count,
      headcount: paid.count,
      totals: { total: total, average: average, median: median, min: min_amount, max: max_amount },
      groups: grouped(paid, levels),
      distribution_counts: distribution_counts(paid, min_amount, max_amount),
      level_ranks: levels.to_h { |id, _name, rank| [ id, rank ] }
    ).as_json
  end

  private

  attr_reader :query

  def totals_for(paid)
    paid.pick(
      Arel.sql("COALESCE(SUM(reporting_amount), 0)"),
      Arel.sql("AVG(reporting_amount)"),
      Arel.sql("percentile_cont(0.5) WITHIN GROUP (ORDER BY reporting_amount)"),
      Arel.sql("MIN(reporting_amount)"),
      Arel.sql("MAX(reporting_amount)")
    )
  end

  def grouped(paid, levels)
    paid = paid.unscope(:order)
    {
      country: grouped_by(paid, "country_id"),
      department: grouped_by(paid, "department_id"),
      job_title: grouped_by(paid, "job_title_id"),
      employment_level: grouped_by(paid, "employment_level_id"),
      country_names: Country.pluck(:id, :name).to_h,
      department_names: Department.pluck(:id, :name).to_h,
      job_title_names: JobTitle.pluck(:id, :title).to_h,
      level_names: levels.to_h { |id, name, _rank| [ id, name ] }
    }
  end

  def grouped_by(relation, column)
    relation.group("employees.#{column}").pluck(
      Arel.sql("employees.#{column}"),
      Arel.sql("COUNT(*)"),
      Arel.sql("SUM(reporting_amount)"),
      Arel.sql("AVG(reporting_amount)"),
      Arel.sql("percentile_cont(0.5) WITHIN GROUP (ORDER BY reporting_amount)")
    ).map do |id, headcount, total_amount, average_amount, median_amount|
      {
        id: id.to_i,
        headcount: headcount.to_i,
        total: total_amount,
        average: average_amount,
        median: median_amount
      }
    end
  end

  def distribution_counts(paid, min_amount, max_amount)
    return {} if min_amount.nil? || max_amount.nil?
    return {} if BigDecimal(min_amount.to_s) == BigDecimal(max_amount.to_s)

    bucket_sql = Employee.sanitize_sql_array([
      "LEAST(?, GREATEST(1, width_bucket(reporting_amount, ?, ?, ?)))",
      DISTRIBUTION_BUCKETS,
      min_amount,
      max_amount,
      DISTRIBUTION_BUCKETS
    ])
    paid.group(Arel.sql(bucket_sql)).count.transform_keys(&:to_i)
  end
end
