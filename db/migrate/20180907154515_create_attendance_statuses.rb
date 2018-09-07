class CreateAttendanceStatuses < ActiveRecord::Migration
  def change
    create_table :attendance_statuses do |t|
      t.string :status
      t.references :person, index: true, foreign_key: true
      t.references :conference, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :attendance_statuses, [:person_id, :conference_id], unique: true
  end
end
