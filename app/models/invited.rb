# frozen_string_literal: true
class Invited < ActiveRecord::Base
  self.table_name = 'invites'

  belongs_to :person
  belongs_to :conference
end
