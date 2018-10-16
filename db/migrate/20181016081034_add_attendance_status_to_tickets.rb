class AddAttendanceStatusToTickets < ActiveRecord::Migration
  def change
    add_reference :tickets, :attendance_status, index: true, foreign_key: true
  end
end
