class Dif < ActiveRecord::Base
  serialize :travel_support, Array

  belongs_to :person

  validates :travel_support, presence: true
end
