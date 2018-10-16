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


  def event
    self.object if self.object_type == "Event"
  end

  def person
    self.object if self.object_type == "Person"
  end

end
