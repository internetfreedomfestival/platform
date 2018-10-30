class AddPaymentIdFromTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :payment_id, :string
  end
end
