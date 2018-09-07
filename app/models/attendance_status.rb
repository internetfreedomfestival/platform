class AttendanceStatus < ActiveRecord::Base
  INVITED = 'invited'.freeze
  REQUESTED = 'requested'.freeze
  REGISTERED = 'registered'.freeze

  STATUSES = [INVITED, REQUESTED, REGISTERED]

  belongs_to :person
  belongs_to :conference

  validates_uniqueness_of [:person_id, :conference_id]
  validates_inclusion_of :status, in: STATUSES
end
