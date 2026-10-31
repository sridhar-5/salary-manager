class Ability
  include CanCan::Ability

  REFERENCE_MODELS = [
    Country,
    Currency,
    Department,
    JobTitle,
    EmploymentLevel,
    JobTitleLevel
  ].freeze

  OPERATIONAL_MODELS = [
    Employee,
    CompensationRecord,
    SalaryBand,
    ExchangeRate
  ].freeze

  def initialize(admin_user)
    return if admin_user.blank?

    can :read, AdminUser, id: admin_user.id
    can :update, AdminUser, id: admin_user.id

    if admin_user.has_role?(:super_admin)
      can :manage, :all
    end

    if admin_user.has_role?(:compensation_admin)
      can :read, OPERATIONAL_MODELS + REFERENCE_MODELS
      can :manage, OPERATIONAL_MODELS
    end

    if admin_user.has_role?(:viewer)
      can :read, OPERATIONAL_MODELS + REFERENCE_MODELS
    end
  end
end
