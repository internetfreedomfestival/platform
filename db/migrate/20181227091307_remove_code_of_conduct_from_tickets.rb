class RemoveCodeOfConductFromTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :code_of_conduct, :string
  end
end
