require 'test_helper'

class AttendanceStatusTest < ActiveSupport::TestCase
  should belong_to :conference
  should belong_to :person
  should validate_uniqueness_of(:conference_id).scoped_to(:person_id)
  should validate_inclusion_of(:status).in_array(AttendanceStatus::STATUSES)

  setup do
    @person = create(:person)
    @conference = create(:conference)
  end

  test 'a person has a attendance status for a conference' do
    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::INVITED
    )

    assert attendance_status.valid?
  end

  test 'a person has different attendance statuses for different conferences' do
    other_conference = create(:conference)
    AttendanceStatus.create(
      person: @person,
      conference: other_conference,
      status: AttendanceStatus::REGISTERED
    )

    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::INVITED
    )

    assert attendance_status.valid?
  end

  test 'a person cannot have more than one attendance status for same conference' do
    AttendanceStatus.create(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::INVITED
    )

    new_attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::REQUESTED
    )

    assert !new_attendance_status.valid?
  end

  test 'a person cannot have a non supported status' do
    new_attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: 'wadus'
    )

    assert !new_attendance_status.valid?
  end

  test 'an attendance status reports itself as invited when a person has been invited to a conference' do
    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::INVITED
    )

    assert_equal true, attendance_status.invited?
  end

  test 'an attendance status reports itself as registered when a person holds a ticket for a conference' do
    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::REGISTERED
    )

    assert_equal true, attendance_status.registered?
  end

  test 'an attendance status reports itself as requested when a person has requested a ticket for a conference' do
    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::REQUESTED
    )

    assert_equal true, attendance_status.requested?
  end
end
