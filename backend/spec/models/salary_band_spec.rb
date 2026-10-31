RSpec.describe SalaryBand, type: :model do
  subject { build(:salary_band) }

  it { is_expected.to belong_to(:country) }
  it { is_expected.to belong_to(:department) }
  it { is_expected.to belong_to(:job_title) }
  it { is_expected.to belong_to(:employment_level) }
  it { is_expected.to belong_to(:currency) }

  it { is_expected.to validate_presence_of(:min_salary) }
  it { is_expected.to validate_numericality_of(:min_salary).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:max_salary) }
  it { is_expected.to validate_numericality_of(:max_salary).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:effective_from) }

  it "does not allow max_salary below min_salary" do
    band = build(:salary_band, min_salary: 100_000, max_salary: 90_000)

    expect(band).not_to be_valid
    expect(band.errors[:max_salary]).to include("must be greater than or equal to the minimum salary")
  end

  it "does not allow effective_to before effective_from" do
    band = build(:salary_band, effective_from: Date.current, effective_to: Date.yesterday)

    expect(band).not_to be_valid
    expect(band.errors[:effective_to]).to include("must be on or after the effective from date")
  end

  it "is invalid when the level is not linked to the job title" do
    band = create(:salary_band)
    band.employment_level = create(:employment_level)

    expect(band).not_to be_valid
    expect(band.errors[:employment_level]).to include("is not applicable to the selected job title")
  end

  it "is invalid when the job title belongs to another department" do
    band = create(:salary_band)
    band.department = create(:department)

    expect(band).not_to be_valid
    expect(band.errors[:job_title]).to include("must belong to the selected department")
  end
end
