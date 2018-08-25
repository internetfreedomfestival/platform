class RemovePersonFromPerson < ActiveRecord::Migration
  def change
    remove_column :people, :Person, :string
  end
end
