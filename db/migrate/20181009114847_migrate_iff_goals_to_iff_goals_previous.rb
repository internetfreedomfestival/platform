class MigrateIffGoalsToIffGoalsPrevious < ActiveRecord::Migration
  def change
    Person.all.each do |person|
      person.update_column(:iff_goals_previous, person.iff_goals) if person.iff_goals.is_a?(String)
    end
  end
end
