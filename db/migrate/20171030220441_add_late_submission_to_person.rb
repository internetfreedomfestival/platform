class AddLateSubmissionToPerson < ActiveRecord::Migration
  def change
    add_column :people, :late_event_submit, :boolean, default: false
  end
end
