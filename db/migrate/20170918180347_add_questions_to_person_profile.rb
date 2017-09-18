class AddQuestionsToPersonProfile < ActiveRecord::Migration
  def change
    add_column :people, :iff_goals, :text
    add_column :people, :challenges, :text
    add_column :people, :other_resources, :text
  end
end
