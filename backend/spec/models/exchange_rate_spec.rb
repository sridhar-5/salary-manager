RSpec.describe ExchangeRate, type: :model do
  subject { build(:exchange_rate) }

  it { is_expected.to belong_to(:base_currency).class_name("Currency") }
  it { is_expected.to belong_to(:quote_currency).class_name("Currency") }

  it { is_expected.to validate_presence_of(:rate) }
  it { is_expected.to validate_numericality_of(:rate).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:effective_date) }

  describe "uniqueness" do
    subject { create(:exchange_rate) }

    it { is_expected.to validate_uniqueness_of(:quote_currency_id).scoped_to(:base_currency_id, :effective_date) }
  end

  it "does not allow the same base and quote currency" do
    currency = create(:currency)
    rate = build(:exchange_rate, base_currency: currency, quote_currency: currency)

    expect(rate).not_to be_valid
    expect(rate.errors[:quote_currency]).to include("must be different from the base currency")
  end
end
