class Cfp::ConfirmationsController < ApplicationController
  layout 'signup'

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    @conference = Conference.find_by_acronym(params[:conference_acronym])

    # re-send
    if @user and @user.send_confirmation_instructions(@conference)
      redirect_to new_cfp_session_path, notice: t(:"cfp.confirmation_instructions_sent")
    else
      redirect_to new_cfp_session_path, notice: t(:"cfp.confirmation_instructions_sent")
    end
  end

  def show
    @user = User.confirm_by_token(params[:confirmation_token])

    if @user
      login_as @user
      redirect_to cfp_person_path, notice: t('cfp.successfully_confirmed')
    else
      redirect_to new_cfp_user_confirmation_path, error: t('cfp.error_confirming')
    end
  end

  def confirm_attendance
    confirmation_token = params[:confirm_attendance_token]
    user = User.find_by(confirm_attendance_token: confirmation_token)
    if user
      person = user.person
      if person.update(attendance_status: "confirmed")
        flash[:sucess] = "Your attendance status has been confirmed!"
      else
        flash[:danger] = "There was an error updating your attendance status. Please contact us."
      end
    end
    redirect_to(cfp_person_path(person.id))
  end
end
