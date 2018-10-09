class CleanUpIffGoalsFromPerson < ActiveRecord::Migration
  def up
    Person.where.not(iff_goals_previous: nil).update_all(iff_goals: [])
  end

  def down
    puts "WARNING: Non recoverable migration, nothing done"
  end
end
