# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # CanCanCan automatically creates these built-in aliases
    # alias_action :index, :show,     :to => :read
    # alias_action :new, create       :to => :create
    # alias_action :edit, update      :to => :update
    # alias_action :destroy,          :to => :destroy

    if user.admin?
      can :manage, :all
    elsif user.moderator?
      can :read, :all
      can :manage, [Post, Movie, Product] # moderators can edit main content
    else # regular user
      # Public read access for non-sensitive data
      can :read, [Movie, Actress, Product, Category]

      # Users can fully manage their own resources
      can :manage, Post, user_id: user.id
      can :manage, Card, user_id: user.id
      can :manage, RingCard, user_id: user.id

      # Employee / profile stuff (only their own)
      can [:read, :update], EmployeeInfo, user_id: user.id
      can :read, Profile, employee_info: { user_id: user.id }

      # They can see their own login sessions
      can :read, Session, user_id: user.id
    end
  end
end
