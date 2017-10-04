class Dif < ActiveRecord::Base
  serialize :travel_support, Array
  belongs_to :person
  validates_inclusion_of :willing_to_facilitate, :past_travel_assistance, :in => [true, false]
  validates :travel_support, presence: true
end
