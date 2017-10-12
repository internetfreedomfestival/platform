class AddTwitterAndWebsiteToPerson < ActiveRecord::Migration
  def change
        add_column :people, :twitter, :string
        add_column :people, :personal_website, :string
  end
end
