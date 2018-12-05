class AttendanceStatus < ActiveRecord::Base
  INVITED = 'Invited'.freeze
  REQUESTED = 'Requested'.freeze
  ON_HOLD = 'On Hold'.freeze
  REGISTERED = 'Holds Ticket'.freeze
  REJECTED = 'Rejected'.freeze

  STATUSES = [INVITED, REQUESTED, ON_HOLD, REGISTERED, REJECTED].freeze

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

  def on_hold?
    status == ON_HOLD
  end

  def registered?
    status == REGISTERED
  end

  def rejected?
    status == REJECTED
  end
end
