class Ticket < ActiveRecord::Base
  serialize :iff_before, Array
  serialize :iff_goals, Array
  serialize :iff_days, Array

  belongs_to :object, polymorphic: true
  belongs_to :conference
  belongs_to :person

  validates_presence_of :public_name,
                        :gender_pronoun,
                        :interested_in_volunteer

  validates :code_of_conduct, acceptance: true
  validates :iff_before, presence: true
  validates :iff_goals, presence: true
  validates :iff_days, presence: true
  validates :ticket_option, presence: {message: "You must select a valid ticket option"}
  validates :amount, presence: {message: "Please, select an amount"}


  def event
    self.object if self.object_type == "Event"
  end
end
