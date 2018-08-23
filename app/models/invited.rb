# frozen_string_literal: true
class Invited < ActiveRecord::Base
  MAX_INVITES_PER_USER = 3

  self.table_name = 'invites'

  belongs_to :person
  belongs_to :conference

  def self.pending_invites_for(person)
    sent_invites = Invited.where(person_id: person.id).count

    MAX_INVITES_PER_USER - sent_invites
  end
end
