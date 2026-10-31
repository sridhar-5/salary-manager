RSpec.describe JobTitleLevel, type: :model do
  subject { build(:job_title_level) }

  it { is_expected.to belong_to(:job_title) }
  it { is_expected.to belong_to(:employment_level) }

  it { is_expected.to validate_uniqueness_of(:employment_level_id).scoped_to(:job_title_id) }
end
