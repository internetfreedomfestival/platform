class ChangePublicTypeFromEvents < ActiveRecord::Migration
  def change
    change_column :events, :public_type, :text
  end
end
