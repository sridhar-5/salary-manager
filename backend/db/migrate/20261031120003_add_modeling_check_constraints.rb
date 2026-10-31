class AddModelingCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :employment_levels, :rank, unique: true

    add_check_constraint :salary_bands, "min_salary > 0", name: "salary_bands_min_salary_positive"
    add_check_constraint :salary_bands, "max_salary >= min_salary", name: "salary_bands_max_salary_gte_min"
    add_check_constraint :salary_bands,
      "effective_to IS NULL OR effective_to >= effective_from",
      name: "salary_bands_effective_range"

    add_check_constraint :exchange_rates, "rate > 0", name: "exchange_rates_rate_positive"
    add_check_constraint :exchange_rates,
      "base_currency_id <> quote_currency_id",
      name: "exchange_rates_currencies_differ"
  end
end
