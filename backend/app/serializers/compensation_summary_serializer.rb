class CompensationSummarySerializer
  DISTRIBUTION_BUCKETS = 8

  def initialize(reporting_currency:, filters:, population:, unconverted_count:, headcount:, totals:, groups:, distribution_counts:, level_ranks:)
    @reporting_currency = reporting_currency
    @filters = filters
    @population = population
    @unconverted_count = unconverted_count
    @headcount = headcount
    @totals = totals
    @groups = groups
    @distribution_counts = distribution_counts
    @level_ranks = level_ranks
  end

  def as_json
    by_country = breakdown(groups[:country], groups[:country_names]).sort_by { |row| row[:name].to_s }
    by_department = breakdown(groups[:department], groups[:department_names]).sort_by { |row| row[:name].to_s }
    by_job_title = breakdown(groups[:job_title], groups[:job_title_names]).sort_by { |row| row[:name].to_s }
    by_level = breakdown(groups[:employment_level], groups[:level_names])
      .sort_by { |row| level_ranks[row[:id]] || 0 }

    {
      reporting_currency: MoneyFormat.currency(reporting_currency),
      filters: filters,
      population: population,
      unconverted_count: unconverted_count,
      headcount: headcount,
      total_annual_compensation: MoneyFormat.format_money(totals[:total]),
      average_salary: MoneyFormat.format_money(totals[:average]),
      median_salary: MoneyFormat.format_money(totals[:median]),
      distribution: distribution(totals[:min], totals[:max]),
      by_country: by_country,
      by_department: by_department,
      by_job_title: by_job_title,
      by_employment_level: by_level,
      insights: {
        highest_median_department: highest_median(by_department),
        highest_median_country: highest_median(by_country),
        highest_median_level: highest_median(by_level)
      }
    }
  end

  private

  attr_reader :reporting_currency, :filters, :population, :unconverted_count, :headcount, :totals, :groups, :distribution_counts, :level_ranks

  def breakdown(rows, names)
    rows.map do |row|
      {
        id: row[:id],
        name: names[row[:id]],
        headcount: row[:headcount],
        total: MoneyFormat.format_money(row[:total]),
        average: MoneyFormat.format_money(row[:average]),
        median: MoneyFormat.format_money(row[:median])
      }
    end
  end

  def highest_median(rows)
    candidates = rows.select { |row| row[:median].present? }
    return nil if candidates.empty?

    best = candidates.max_by { |row| BigDecimal(row[:median]) }
    { id: best[:id], name: best[:name], median: best[:median] }
  end

  def distribution(min_amount, max_amount)
    return [] if min_amount.nil? || max_amount.nil?

    min = BigDecimal(min_amount.to_s)
    max = BigDecimal(max_amount.to_s)
    if min == max
      return [ { min: MoneyFormat.format_money(min), max: MoneyFormat.format_money(max), count: headcount } ]
    end

    width = (max - min) / DISTRIBUTION_BUCKETS
    (1..DISTRIBUTION_BUCKETS).map do |bucket|
      lower = min + (width * (bucket - 1))
      upper = bucket == DISTRIBUTION_BUCKETS ? max : min + (width * bucket)
      { min: MoneyFormat.format_money(lower), max: MoneyFormat.format_money(upper), count: distribution_counts[bucket] || 0 }
    end
  end
end
