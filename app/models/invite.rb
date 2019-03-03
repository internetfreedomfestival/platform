# frozen_string_literal: true
class Invite < ActiveRecord::Base
  before_validation :normalize_email

  validates_uniqueness_of :email, scope: :conference_id

  REGULAR_INVITES_PER_USER = 5

  belongs_to :person
  belongs_to :conference

  def self.pending_invites_for(person, conference)
    attendance_status = AttendanceStatus.find_by(person: person, conference: conference)

    return 0 unless attendance_status&.invited? || attendance_status&.registered?

    sent_invites = Invite.where(person: person, conference: conference).count
    granted_invites = InvitesAssignation.find_by(person: person, conference: conference)&.number

    if granted_invites.blank?
      granted_invites = sharing_allowed_for?(person, conference) ? REGULAR_INVITES_PER_USER : 0
    end

    [0, (granted_invites - sent_invites)].max
  end

  def self.sharing_allowed_for?(person, conference)
    invitation = Invite.find_by(email: person.email.downcase, conference: conference)

    return false unless invitation.present?

    invitation.sharing_allowed?
  end

  def normalize_email
    self.email = email.strip.downcase
  end
end
