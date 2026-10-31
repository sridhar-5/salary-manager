RSpec.describe JobTitle, type: :model do
  subject { build(:job_title) }

  it { is_expected.to belong_to(:department) }
  it { is_expected.to have_many(:job_title_levels).dependent(:destroy) }
  it { is_expected.to have_many(:employment_levels).through(:job_title_levels) }
  it { is_expected.to have_many(:employees).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:salary_bands).dependent(:restrict_with_error) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:title).scoped_to(:department_id) }
  it { is_expected.to validate_length_of(:title).is_at_most(150) }
end
