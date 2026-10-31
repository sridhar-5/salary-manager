RSpec.describe Ability, type: :model do
  let(:viewer) { create(:admin_user, :viewer) }
  let(:compensation_admin) { create(:admin_user, :compensation_admin) }
  let(:super_admin) { create(:admin_user, :super_admin) }

  it "grants nothing without an admin" do
    ability = Ability.new(nil)

    expect(ability).not_to be_able_to(:read, Employee)
  end

  it "lets a viewer read operational and reference data only" do
    ability = Ability.new(viewer)

    expect(ability).to be_able_to(:read, Employee)
    expect(ability).to be_able_to(:read, Country)
    expect(ability).not_to be_able_to(:create, Employee)
    expect(ability).not_to be_able_to(:create, Country)
    expect(ability).not_to be_able_to(:read, Role.new)
    expect(ability).to be_able_to(:read, viewer)
    expect(ability).to be_able_to(:update, viewer)
    expect(ability).not_to be_able_to(:read, compensation_admin)
  end

  it "lets a compensation admin manage pay data and read reference data" do
    ability = Ability.new(compensation_admin)

    expect(ability).to be_able_to(:manage, Employee)
    expect(ability).to be_able_to(:manage, CompensationRecord)
    expect(ability).to be_able_to(:read, Country)
    expect(ability).not_to be_able_to(:create, Country)
    expect(ability).not_to be_able_to(:read, Role.new)
  end

  it "lets a super admin manage everything" do
    ability = Ability.new(super_admin)

    expect(ability).to be_able_to(:manage, Role.new)
    expect(ability).to be_able_to(:manage, Country)
    expect(ability).to be_able_to(:manage, compensation_admin)
  end
end
