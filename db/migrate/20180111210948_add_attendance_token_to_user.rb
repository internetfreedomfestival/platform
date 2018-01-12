class AddAttendanceTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :confirm_attendance_token, :string
  end
end
