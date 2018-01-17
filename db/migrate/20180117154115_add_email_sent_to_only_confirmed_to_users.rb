class AddEmailSentToOnlyConfirmedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_sent_to_confirmed_only, :datetime
  end
end
