module MoneyFormat
  module_function

  def format_money(value)
    return nil if value.nil?

    format("%.4f", BigDecimal(value.to_s))
  end

  def currency(currency)
    return nil if currency.blank?

    { id: currency.id, code: currency.code, name: currency.name }
  end
end
