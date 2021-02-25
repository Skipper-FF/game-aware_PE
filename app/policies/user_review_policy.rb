class UserReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    update?
  end

  def update?
    true if owner?
  end

  def destroy?
    true if owner?
  end

private

  def owner?
    record.user == user
  end
end
