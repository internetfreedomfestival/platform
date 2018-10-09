class CleanUpIffGoalsFromPerson < ActiveRecord::Migration
  def change
    Person.all.each do |person|
      person.update_column(:iff_goals, []) unless person.iff_goals_previous.nil?
    end
  end
end
