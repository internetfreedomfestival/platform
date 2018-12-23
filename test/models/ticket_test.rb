require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  should belong_to :conference
  should belong_to :person
  should validate_presence_of :public_name
  should validate_presence_of :gender_pronoun
  should validate_presence_of :interested_in_volunteer
  should validate_presence_of :iff_before
  should validate_presence_of :iff_goals
  should validate_presence_of :iff_days
  should validate_acceptance_of :code_of_conduct
  should validate_presence_of(:ticket_option).with_message(/select a valid ticket option/)
  should validate_presence_of(:amount).with_message(/select an amount/)
  should validate_uniqueness_of(:conference_id).scoped_to(:person_id)

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
