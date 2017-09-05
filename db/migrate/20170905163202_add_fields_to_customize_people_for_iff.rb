class AddFieldsToCustomizePeopleForIff < ActiveRecord::Migration
  def change
    add_column :people, :pgp_key, :text
    add_column :people, :country_of_origin, :string
    add_column :people, :professional_background, :string
    add_column :people, :other_background, :text
    add_column :people, :organization, :string
    add_column :people, :project, :string
    add_column :people, :title, :string
    add_column :people, :iff_before, :string
    add_column :people, :invitation_to_mattermost, :boolean, null: false, default: false
    add_column :people, :interested_in_volunteer, :boolean, null: false, default: false
  end
end
