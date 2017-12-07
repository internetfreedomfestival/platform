class AddEtherPadUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :etherpad_url, :string
  end
end
