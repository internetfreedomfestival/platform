require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  should belong_to :conference
  should belong_to :person
  should validate_uniqueness_of(:email).scoped_to(:conference_id)

  test 'normalizes invitee email addresses' do
    invite = create(:invite, email: ' SomeNonNormalizedEmail@Domain.Com ')

    assert_equal 'somenonnormalizedemail@domain.com', invite.email
  end

  test 'allows invite sharing' do
    invitee = create(:person)
    conference = create(:conference)
    create(:invite, email: invitee.email, conference: conference, sharing_allowed: true)
    create(:attendance_status, person: invitee, conference: conference, status: AttendanceStatus::INVITED)

    assert Invite.pending_invites_for(invitee, conference).positive?
  end

  test 'forbids invite sharing' do
    invitee = create(:person)
    conference = create(:conference)
    create(:invite, email: invitee.email, conference: conference, sharing_allowed: false)
    create(:attendance_status, person: invitee, conference: conference, status: AttendanceStatus::INVITED)

    assert_equal 0, Invite.pending_invites_for(invitee, conference)
  end
end
