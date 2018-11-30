class EnableSharingAllowedWhenApplicable < ActiveRecord::Migration
  def up
    # ALERT!
    # This is highly dependent on the actual database values, so there is no
    # guarantee of a deterministic outcome.

    conference = Conference.find_by(acronym: 'IFF2019')
    invitations = Invited.where(conference: conference)

    invitations.each do |invitation|
      inviter = invitation.person
      value = (inviter.user.role == 'admin')

      Rails.logger.info "Updating invitation: #{invitation.inspect}"
      Rails.logger.info "  Inviter ##{inviter.id} has role \"#{inviter.user.role}\": setting sharing_allowed to #{value} for invitation ##{invitation.id}"

      invitation.update(sharing_allowed: value)
    end
  end

  def down
    Rails.logger.info 'Nothing to do here!'
  end
end
