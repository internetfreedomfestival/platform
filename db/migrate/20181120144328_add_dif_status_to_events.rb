class AddDifStatusToEvents < ActiveRecord::Migration
  def change
    add_column :events, :dif_status, :string
  end
end
