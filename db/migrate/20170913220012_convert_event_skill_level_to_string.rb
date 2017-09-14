class ConvertEventSkillLevelToString < ActiveRecord::Migration
  def change
    change_column :events, :skill_level, :string
  end
end
