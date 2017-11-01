class AddAttendanceStatusToPerson < ActiveRecord::Migration
  def change
    add_column :people, :attendance_status, :string
  end
end
