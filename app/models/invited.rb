# frozen_string_literal: true
class Invited < ActiveRecord::Base
  before_validation :normalize_email

  REGULAR_INVITES_PER_USER = 5

  self.table_name = 'invites'

  belongs_to :person
  belongs_to :conference

  def self.pending_invites_for(person, conference)
    sent_invites = Invited.where(person: person, conference: conference).count
    granted_invites = InvitesAssignation.find_by(person: person, conference: conference)

    [0, (granted_invites&.number || REGULAR_INVITES_PER_USER) - sent_invites].max
  end

  def normalize_email
    self.email = email.strip
  end
end
