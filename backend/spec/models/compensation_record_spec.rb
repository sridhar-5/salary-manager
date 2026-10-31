RSpec.describe CompensationRecord, type: :model do
  subject { build(:compensation_record) }

  it { is_expected.to belong_to(:employee) }
  it { is_expected.to belong_to(:currency) }
  it { is_expected.to belong_to(:created_by).class_name("AdminUser") }

  it { is_expected.to validate_presence_of(:annual_salary) }
  it { is_expected.to validate_numericality_of(:annual_salary).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:effective_from) }
  it { is_expected.to validate_presence_of(:created_by_id) }

  it "does not allow effective_to before effective_from" do
    record = build(:compensation_record, effective_from: Date.current, effective_to: Date.yesterday)

    expect(record).not_to be_valid
    expect(record.errors[:effective_to]).to include("must be on or after the effective from date")
  end

  it "requires the employee country currency" do
    record = build(:compensation_record, currency: create(:currency))

    expect(record).not_to be_valid
    expect(record.errors[:currency]).to include("must match the employee country currency")
  end

  describe "change capture" do
    it "records a create version" do
      admin = create(:admin_user)
      record = PaperTrail.request(whodunnit: admin.id.to_s) do
        create(:compensation_record, created_by: admin)
      end

      version = record.versions.sole
      expect(version.event).to eq("create")
      expect(version.whodunnit).to eq(admin.id.to_s)
    end

    it "does not overwrite salary on a normal update" do
      record = create(:compensation_record)

      expect(record.update(annual_salary: 150_000)).to be(false)
      expect(record.errors[:annual_salary]).to include("cannot be changed; create a new compensation record instead")
    end

    it "cannot be deleted" do
      record = create(:compensation_record)

      expect(record.destroy).to be(false)
      expect(record.errors[:base]).to include("Compensation records cannot be deleted")
      expect(record.reload).to be_persisted
    end
  end
end
