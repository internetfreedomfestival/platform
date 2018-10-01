class RemovePhoneNumberFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :phone_prefix, :string
  end
end
