class Cfp::UsersController < ApplicationController
  layout 'signup'

  before_action :authenticate_user!, only: [:edit, :update]

  def new
    @form = SignUpForm.new
  end

  def create
    @form = SignUpForm.new(sign_up_form_params)

    if @form.valid?
      person = Person.new(
        email: @form.email,
        email_confirmation: @form.email_confirmation,
        first_name: @form.first_name,
        last_name: @form.last_name,
        pgp_key: @form.pgp_key,
        gender: @form.gender,
        country_of_origin: @form.country_of_origin,
        group: @form.group,
        professional_background: @form.professional_background.reject{|value| value.blank?},
        other_background: @form.other_background,
        organization: @form.organization,
        project: @form.project,
        include_in_mailings: @form.include_in_mailings,
        invitation_to_mattermost: @form.invitation_to_mattermost
      )
      user = User.new(
        email: @form.email,
        password: @form.password,
        password_confirmation: @form.password_confirmation,
        person: person
      )
      conference = Conference.find_by_acronym(params[:conference_acronym])

      if user.save
        if Invited.find_by(email: user.email, conference: conference)
          AttendanceStatus.create!(person: person, conference: conference, status: AttendanceStatus::INVITED)
        end
        user.send_confirmation_instructions(conference)
        redirect_to new_cfp_session_path, notice: t(:"cfp.signed_up")
        return
      end
    end

    render action: 'new'
  end

  def edit
    @user = current_user
    render layout: 'cfp'
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      redirect_to cfp_person_path, notice: t(:"cfp.updated")
    else
      render action: 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def sign_up_form_params
    params.require(:sign_up_form).permit(
      :email, :email_confirmation,
      :password, :password_confirmation,
      :first_name,
      :last_name,
      :pgp_key,
      :gender,
      :country_of_origin,
      :group,
      :other_background,
      :organization,
      :project,
      :include_in_mailings,
      :invitation_to_mattermost,
      professional_background: []
    )
  end
end
