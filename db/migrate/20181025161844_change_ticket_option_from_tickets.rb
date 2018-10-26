class ChangeTicketOptionFromTickets < ActiveRecord::Migration
  def change
    change_column  :tickets, :ticket_option, :string
  end
end

