class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
      cannot :destroy, User, id: user.id
    else
      can :update, User, id: user.id
      can :create, Invitation
      can :manage, Record, user_id: user.id
      can :manage, Song, record: {user_id: user.id}
      can :manage, Photo, record: {user_id: user.id}
      # need solution for labels and artists
      can :read, :all
    end
  end
end
