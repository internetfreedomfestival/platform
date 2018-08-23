class Cfp::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def send(*)
    if params['email'].blank?
      flash[:error] = 'Email cannot be blank'
      redirect_to cfp_root_path
      return
    end

    email = params['email']
    acronym = params['conference_acronym']
    person = current_user.person
    conference = Conference.find_by(acronym: acronym)

    if Invited.pending_invites_for(person) == 0
      flash[:error] = 'You have already sent all your available invitations'
      redirect_to cfp_root_path
      return
    end

    invited = Invited.create(email: email, person: person, conference: conference)
    InvitationMailer.additional_invitation_mail(invited).deliver_now

    flash[:notice] = "We have sent an invite to #{params['email']}"
    redirect_to cfp_root_path
  end
end
