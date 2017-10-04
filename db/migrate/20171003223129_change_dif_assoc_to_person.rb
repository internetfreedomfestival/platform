class ChangeDifAssocToPerson < ActiveRecord::Migration
  def change
    remove_column :difs, :event_person_id
    add_column :difs, :person_id, :integer
  end
end
