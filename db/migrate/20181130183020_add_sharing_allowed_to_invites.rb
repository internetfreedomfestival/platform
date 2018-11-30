class AddSharingAllowedToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :sharing_allowed, :boolean
  end
end
