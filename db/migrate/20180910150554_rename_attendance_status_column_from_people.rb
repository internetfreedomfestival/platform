class RenameAttendandeStatusColumnFromPeople < ActiveRecord::Migration
  def change
    rename_column :people, :attendance_status, :old_attendance_status
  end
end
