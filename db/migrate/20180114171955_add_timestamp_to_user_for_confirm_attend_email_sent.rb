class AddTimestampToUserForConfirmAttendEmailSent < ActiveRecord::Migration
  def change
      add_column :users, :confirm_attendance_email_sent, :datetime
  end
end
