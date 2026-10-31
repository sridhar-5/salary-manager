RSpec.describe EmploymentLevel, type: :model do
  subject { build(:employment_level) }

  it { is_expected.to have_many(:job_title_levels).dependent(:destroy) }
  it { is_expected.to have_many(:job_titles).through(:job_title_levels) }
  it { is_expected.to have_many(:employees).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }

  it { is_expected.to validate_presence_of(:rank) }
  it { is_expected.to validate_numericality_of(:rank).only_integer }
end
