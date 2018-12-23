class AddEmailToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :email, :string
  end
end
