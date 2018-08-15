class AddGenderPronounIffDaysToPerson < ActiveRecord::Migration
  def change
    add_column :people, :gender_pronoun, :string
    add_column :people, :iff_days, :string
  end
end
