class RecordPolicy < ApplicationPolicy

  def edit?
    owner?
  end

  def update?
    owner?
  end

  protected

  def owner?
    user == record.user
  end
end
