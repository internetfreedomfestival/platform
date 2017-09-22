class AddAlreadyMailMattermostToPeople < ActiveRecord::Migration
  def change
    add_column :people, :already_mailing, :boolean
    add_column :people, :already_mattermost, :boolean
  end
end
