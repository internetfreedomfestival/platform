class CreateInvitesTable < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.references :person, index: true, foreign_key: true
      t.references :conference, index: true, foreign_key: true
    end
  end
end
