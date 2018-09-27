class AddEventToDifs < ActiveRecord::Migration
  def change
    add_reference :difs, :event, index: true, foreign_key: true
  end
end
