class AddPhoneNumberToEvents < ActiveRecord::Migration
  def change
    add_column :events, :phone_number, :string
    add_column :events, :phone_prefix, :string
  end
end
