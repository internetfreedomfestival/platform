class ChangePublicNameFromPerson < ActiveRecord::Migration
  def change
    change_column_null :people, :public_name, true
  end
end
