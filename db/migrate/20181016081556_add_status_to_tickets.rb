class AddStatusToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :status, :string
  end
end
