class Cfp::PeopleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :obtain_person, except: [:new]
  before_action :check_cfp_open

  def show
    @not_registered = (@person.public_name == "Enter a public name here")
    @old_account = person_needs_to_upgrade
    @no_events = @person.events.empty?
    @no_dif = @person.dif.nil?
    @is_fellow = ConferenceUser.exists?(user_id: current_user.id)
    @attendance_status = AttendanceStatus.find_by(person: @person, conference: @conference)


    @invites = 0
    @invites = Invited.pending_invites_for(@person) if @person.allowed_to_send_invites?

    @invited = Invited.find_by(email: @person.email)

    return redirect_to action: 'new' unless @person

    if @person.public_name == current_user.email
      flash[:alert] = 'Your email address is not a valid public name, please change it.'
      redirect_to action: 'edit'
    end
  end

  def new
    @person = Person.new(email: current_user.email)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @person }
    end
  end

  def edit
    @first_time = (@person.public_name == 'Enter a public name here')

    if @person.nil?
      flash[:alert] = 'Not a valid person'
      redirect_to action: :index
    end
  end

  def create
    if @person.nil?
      @person = Person.new(person_params)
      @person.user = current_user
    end

    respond_to do |format|
      if @person.save
        format.html { redirect_to(cfp_person_path, notice: t('cfp.person_created_notice')) }
        format.xml  { render xml: @person, status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    new_email = person_params[:email]

    if new_email.blank?
      flash[:danger] = "Confirm your email"
      return redirect_to action: :edit
    end

    if new_email != @person.email && Person.where(email: new_email).count > 0
      flash[:danger] = "This email has already been taken"
      return redirect_to action: :edit
    end

    if person_invalid_for_update
      flash[:alert] = "You must fill out all the required fields!"
      return redirect_to action: :edit
    end

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(cfp_person_path, notice: t('cfp.person_updated_notice')) }
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel_attendance
    if @person.update(old_attendance_status: "canceled")
      flash[:alert] = "You have canceled your attendance."
    else
      flash[:alert] = "There was an error cancelling your attendance. Please contact the IFF team."
    end

    redirect_to action: :show
  end

  def confirm_attendance
    if @person.update(old_attendance_status: "confirmed")
      flash[:success] = "You are confirmed to attend the 2018 IFF!"
    else
      flash[:alert] = "There was some issue updating your status. Please contact the IFF team."
    end

    redirect_to action: :show
  end

  private

  def obtain_person
    @person = current_user.person
  end

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_confirmation, :email_public, :gender, :avatar, :group, :abstract, :description, :include_in_mailings, :include_in_mailings, :pgp_key, :country_of_origin, :other_background, :organization, :project, :title, :invitation_to_mattermost, :iff_goals, :challenges, :other_resources, :interested_in_volunteer, :already_mattermost, :already_mailing, :twitter, :personal_website, :complete_mattermost, :complete_mailing, { iff_before: [] }, { professional_background: [] },
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
    )
  end

  def person_invalid_for_update
    if person_params[:email].nil? ||
       person_params[:email_confirmation].nil? || person_params[:email] != person_params[:email_confirmation] ||
       person_params[:first_name] == "" ||
       person_params[:country_of_origin] == "" ||
       person_params[:gender] == "" ||
       person_params[:professional_background].nil? ||
       person_params[:include_in_mailings] == [] ||
       person_params[:invitation_to_mattermost] == []
      return true
    end
  end

  def person_needs_to_upgrade
    if @person.email.nil? || @person.email == "" ||
       @person.first_name == "" ||
       @person.country_of_origin == "" ||
       @person.gender == "" ||
       @person.professional_background.nil? ||
       @person.include_in_mailings == [] ||
       @person.invitation_to_mattermost == []
      return true
    end
  end
end
