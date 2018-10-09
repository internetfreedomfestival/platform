class AddIffGoalsPreviousToPeople < ActiveRecord::Migration
  def change
    add_column :people, :iff_goals_previous, :text
  end
end
