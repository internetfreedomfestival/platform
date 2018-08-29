class Cfp::UsersController < ApplicationController
  layout 'signup'

  before_action :authenticate_user!, only: [:edit, :update]

  def new
    @user = User.new
    @person = Person.new
    @user.person = @person
  end

  def create
    @user = User.new(user_params)
    @person = Person.new(person_params)
    @conference = Conference.find_by_acronym(params[:conference_acronym])
    @person.email = @user.email
    @person.professional_background = params['professional_background']

    @user.person = @person

    if @user.save
      @user.send_confirmation_instructions(@conference)
      redirect_to new_cfp_session_path, notice: t(:"cfp.signed_up")
    else
      render action: 'new'
    end
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

  def person_params
    params.require(:user).require(:person_attributes).permit(:email_confirm, :first_name, :last_name, :pgp_key, :gender, :country_of_origin, :group, :professional_background, :other_background, :organization, :project, :include_in_mailings, :invitation_to_mattermost)
  end
end
