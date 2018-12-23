class Ticket < ActiveRecord::Base
  COMPLETED = 'Completed'.freeze
  PENDING = 'Pending'.freeze
  CANCELED = 'Canceled'.freeze
  TO_REFUND = 'To Refund'.freeze

  STATUSES = [COMPLETED, PENDING, CANCELED, TO_REFUND].freeze

  INDIVIDUAL = 'Individual Ticket'.freeze
  SOLIDARITY = 'Solidarity Ticket'.freeze
  ORGANIZATIONAL = 'Organizational Ticket'.freeze

  OPTIONS = [INDIVIDUAL, SOLIDARITY, ORGANIZATIONAL].freeze

  serialize :iff_before, Array
  serialize :iff_goals, Array
  serialize :iff_days, Array

  belongs_to :object, polymorphic: true
  belongs_to :conference
  belongs_to :person

  validates_presence_of :public_name,
                        :gender_pronoun,
                        :interested_in_volunteer,
                        :iff_before,
                        :iff_goals,
                        :iff_days

  validates :ticket_option, presence: { message: 'You must select a valid ticket option' }
  validates :amount, presence: { message: 'Please, select an amount' }

  validates_acceptance_of :code_of_conduct

  validates_uniqueness_of :conference_id, scope: :person_id

  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :ticket_option, in: OPTIONS

  def event
    self.object if self.object_type == "Event"
  end
end
