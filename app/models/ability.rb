class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #guest
    
    if user.admin?
      can :manage, :all
    else
      can :read, :all
      if user.role?(:author)
        can :create, Record
        can :update, Record do |record|
          record.try(:user) == user
        end
      end
    end
  end
end