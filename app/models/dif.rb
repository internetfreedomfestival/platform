class Dif < ActiveRecord::Base
  serialize :travel_support, Array
  serialize :past_travel_assistance, Array

  belongs_to :person
  belongs_to :event

  validates :travel_support, presence: true
end
