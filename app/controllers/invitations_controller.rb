class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def new
    authorize! :administrate, Person
  end

  def create
    authorize! :administrate, Person

    email = params['email']
    acronym = params['conference_acronym']
    invited_by = current_user.person
    conference = Conference.find_by(acronym: acronym)

    if email.blank?
      flash[:warning] = 'Email cannot be blank'
      render :new
      return
    end

    invited = Invited.create(email: email, person: invited_by, conference: conference)
    InvitationMailer.not_registered_invitation_mail(invited).deliver_now

    redirect_to new_invitations_path, notice: "We have sent an invite to #{invited.email}"
  end
end
