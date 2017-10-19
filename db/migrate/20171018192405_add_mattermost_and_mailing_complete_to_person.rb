class AddMattermostAndMailingCompleteToPerson < ActiveRecord::Migration
  def change
    add_column :people, :complete_mailing, :string
    add_column :people, :complete_mattermost, :string
  end
end
