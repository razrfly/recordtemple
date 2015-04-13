class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
      cannot :destroy, User, id: user.id
    else
      can :create, Invitation
      can :manage, Record, user_id: user.id
      can :manage, Song, record: { user_id: user.id }
      can :manage, Photo, record: { user_id: user.id }
      can :read, :all
      cannot :read, Page
      cannot :read, User
      # doesn't work!
      can :manage, Page, user_id: user.id
      can [:update, :read], User, id: user.id
    end
  end
end
