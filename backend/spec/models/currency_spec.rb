RSpec.describe Currency, type: :model do
  subject { build(:currency) }

  it { is_expected.to have_many(:countries).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code) }
  it { is_expected.to validate_length_of(:code).is_equal_to(3) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
end
