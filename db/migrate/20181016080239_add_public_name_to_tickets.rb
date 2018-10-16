class AddPublicNameToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :public_name, :string
    add_column :tickets, :gender_pronoun, :string
    add_column :tickets, :iff_before, :string
    add_column :tickets, :iff_goals, :string
    add_column :tickets, :iff_days, :string
    add_column :tickets, :interested_in_volunteer, :string
    add_column :tickets, :code_of_conduct, :string
    add_column :tickets, :person_id, :integer
    add_column :tickets, :conference_id, :integer
  end
end
