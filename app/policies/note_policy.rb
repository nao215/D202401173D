# typed: true
# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def destroy?
    user.id == record.user_id
  end
end

# Note: The ApplicationPolicy class is assumed to be already defined as per the project structure.
# The user and record are assumed to be set by the controller when initializing the policy.
