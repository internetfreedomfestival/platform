class AttendanceStatus < ActiveRecord::Base
  INVITED = 'Invited'.freeze
  REQUESTED = 'Requested'.freeze
  REGISTERED = 'Holds Ticket'.freeze
  REJECTED = 'Rejected'.freeze
  ON_HOLD = 'On hold request'.freeze

  STATUSES = [INVITED, REQUESTED, REGISTERED, REJECTED, ON_HOLD].freeze

  belongs_to :person
  belongs_to :conference

  validates_uniqueness_of :conference_id, scope: :person_id
  validates_inclusion_of :status, in: STATUSES

  def invited?
    status == INVITED
  end

  def requested?
    status == REQUESTED
  end

  def registered?
    status == REGISTERED
  end

  def on_hold?
    status == ON_HOLD
  end

  def rejected?
    status == REJECTED
  end
end
