class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :status
      t.references :person, index: true, foreign_key: true
      t.references :conference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
