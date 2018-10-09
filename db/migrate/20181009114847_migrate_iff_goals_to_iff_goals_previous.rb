class MigrateIffGoalsToIffGoalsPrevious < ActiveRecord::Migration
  def up
    Person.find_each do |person|
      person.update_column(:iff_goals_previous, person.iff_goals) if person.iff_goals.is_a?(String)
    end
  end

  def down
    puts "WARNING: Non recoverable migration, nothing done"
  end
end
