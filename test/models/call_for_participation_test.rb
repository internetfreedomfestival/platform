require 'test_helper'

class CallForParticipationTest < ActiveSupport::TestCase
  should belong_to :conference

  should validate_presence_of :start_date
  should validate_presence_of :end_date

  test 'is closed if the end date has passed' do
    cfp = create(:call_for_participation, end_date: Date.yesterday)
    assert cfp.closed?
  end
end
