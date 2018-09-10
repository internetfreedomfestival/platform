require 'test_helper'

class AttendanceStatusTest < ActiveSupport::TestCase
  def setup
    @person = create(:person)
    @conference = create(:conference)
  end

  test "a person has a attendance status for a conference" do
    attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: AttendanceStatus::INVITED
    )

    assert attendance_status.valid?
  end

  test "a person has different attendance statuses for different conferences" do
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

  test "a person cannot have more than one attendance status for same conference" do
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

  test "a person cannot have a non supported status" do
    new_attendance_status = AttendanceStatus.new(
      person: @person,
      conference: @conference,
      status: 'wadus'
    )

    assert !new_attendance_status.valid?
  end
end
