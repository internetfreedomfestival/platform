class CreateInvitesAssignations < ActiveRecord::Migration
  def change
    create_table :invites_assignations do |t|
      t.integer :number
      t.references :person, index: true, foreign_key: true
      t.references :conference, index: true, foreign_key: true
    end
  end
end
