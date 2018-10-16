class RemoveAttendanceStatusToTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :attendance_status_id, :integer
  end
end
