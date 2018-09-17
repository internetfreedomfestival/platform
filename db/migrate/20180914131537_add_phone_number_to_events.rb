class AddPhoneNumberToEvents < ActiveRecord::Migration
  def change
    add_column :events, :phone_number, :integer
    add_column :events, :phone_prefix, :integer
  end
end
