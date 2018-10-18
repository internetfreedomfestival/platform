require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  setup do
    @conference = create(:conference)
    @event = create(:event)
  end

  test 'should create a ticket' do
    ticket = build(:ticket)
    assert ticket.save
  end

  test 'should associate a ticket with an event' do
    ticket = build(:ticket)
    @event.ticket = ticket
    assert @event.save
  end

  test 'should have a person' do
    person = create(:person)
    ticket = create(:ticket, person: person)
    ticket.reload
    assert_not_nil ticket.person
  end

end
