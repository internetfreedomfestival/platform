class AddProjectorToEvents < ActiveRecord::Migration
  def change
    add_column :events, :projector, :boolean
  end
end
