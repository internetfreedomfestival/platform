class AddIffBeforeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :iff_before, :string
  end
end
