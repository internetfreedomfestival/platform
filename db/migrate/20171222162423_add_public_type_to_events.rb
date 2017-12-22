class AddPublicTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :public_type, :string
  end
end
