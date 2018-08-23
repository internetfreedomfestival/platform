class Cfp::InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_is_allowed_to_invite_people
  before_action :check_email_not_blank
  before_action :check_user_has_available_invites
  before_action :check_email_not_invited

  def invite
    email = params['email']
    acronym = params['conference_acronym']
    person = current_user.person
    conference = Conference.find_by(acronym: acronym)

    invited = Invited.create(email: email, person: person, conference: conference)
    InvitationMailer.additional_invitation_mail(invited).deliver_now

    flash[:notice] = "We have sent an invite to #{params['email']}"
    redirect_to cfp_root_path
  end

  private

  def check_user_is_allowed_to_invite_people
    person = current_user.person

    return if person.allowed_to_send_invites?

    flash[:error] = 'Only users invited by an admin can invite colleagues'
    redirect_to cfp_root_path
  end

  def check_email_not_blank
    if params['email'].blank?
      flash[:error] = 'Email cannot be blank'
      redirect_to cfp_root_path
    end
  end

  def check_user_has_available_invites
    person = current_user.person

    if Invited.pending_invites_for(person) == 0
      flash[:error] = 'You have already sent all your available invitations'
      redirect_to cfp_root_path
    end
  end

  def check_email_not_invited
    if Invited.exists?(email: params['email'])
      flash[:error] = 'The user you are trying to invite has already received an invite'
      redirect_to cfp_root_path
    end
  end
end
