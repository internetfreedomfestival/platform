class ChangeDefaultOfPersonToTrue < ActiveRecord::Migration
  def change
    change_column_default(:people, :include_in_mailings, true)
    change_column_default(:people, :interested_in_volunteer, true)
    change_column_default(:people, :invitation_to_mattermost, true)
  end
end
