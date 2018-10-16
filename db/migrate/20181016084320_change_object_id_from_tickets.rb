class ChangeObjectIdFromTickets < ActiveRecord::Migration
  def change
    change_column :tickets, :object_id, :integer, null: true
  end
end
