class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      # Admin can manage everything
      can :manage, :all
    elsif user.super_user?
      # Super user has all user permissions + permanent subscription access
      can :read, :all
      can :manage, User, id: user.id
      can :manage, UserSubscription, user_id: user.id
      can :read, UserPurchaseHistory, user_id: user.id
      can :read, Promotion
      # Super user always has subscription access (handled in User model)
    else
      # Regular user permissions
      can :read, :all
      can :manage, User, id: user.id
      can :manage, UserSubscription, user_id: user.id
      can :read, UserPurchaseHistory, user_id: user.id
      can :read, Promotion
    end
  end
end
