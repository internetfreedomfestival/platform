class AddAttrsToPersonModel < ActiveRecord::Migration
  def change
    add_column :events, :other_presenters, :text
    add_column :events, :desired_outcome, :text
    add_column :events, :theme, :string
    add_column :events, :skill_level, :integer
    add_column :events, :travel_assistance, :boolean
  end
end
