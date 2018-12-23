class Ticket < ActiveRecord::Base
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

  def event
    self.object if self.object_type == "Event"
  end
end
