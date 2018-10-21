class AddTicketOptionFromTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :ticket_option, :integer
  end
end
