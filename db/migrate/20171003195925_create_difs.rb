class CreateDifs < ActiveRecord::Migration
  def change
    create_table :difs do |t|
      t.integer :event_person_id
      t.string  :travel_support
      t.boolean :past_travel_assistance
      t.boolean :willing_to_facilitate
      t.string  :status

      t.timestamps null: false
    end
  end
end
