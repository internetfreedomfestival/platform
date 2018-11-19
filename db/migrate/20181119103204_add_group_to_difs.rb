class AddGroupToDifs < ActiveRecord::Migration
  def change
    add_column :difs, :group, :string
  end
end
