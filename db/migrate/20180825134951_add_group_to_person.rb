class AddGroupToPerson < ActiveRecord::Migration
  def change
    add_column :people, :group, :boolean
  end
end
