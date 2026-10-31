RSpec.describe Country, type: :model do
  subject { build(:country) }

  it { is_expected.to belong_to(:currency) }
  it { is_expected.to have_many(:employees).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }

  it { is_expected.to validate_presence_of(:iso_code) }
  it { is_expected.to validate_length_of(:iso_code).is_equal_to(2) }

  describe "uniqueness" do
    subject { create(:country) }

    it { is_expected.to validate_uniqueness_of(:iso_code) }
  end
end
