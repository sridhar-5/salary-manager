RSpec.describe Department, type: :model do
  subject { build(:department) }

  it { is_expected.to have_many(:job_titles).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:employees).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:salary_bands).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
end
