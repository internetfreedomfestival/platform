class Cfp::PeopleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :obtain_person, except: [:new]
  before_action :check_cfp_open

  def show
    @not_registered = (@person.public_name == "Enter a public name here")
    @is_old_account = person_needs_to_update_profile?
    @no_events = @person.events.empty?
    @no_dif = @person.dif.nil?
    @is_fellow = ConferenceUser.exists?(user_id: current_user.id)
    @attendance_status = AttendanceStatus.find_by(person: @person, conference: @conference)

    @events = @person.events_as_presenter_in(@conference)

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
    params = person_params

    if params[:email] == @person.email
      params = person_params.except(:email, :email_confirmation)
    end

    respond_to do |format|
      if @person.update_attributes(params)
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

  def person_needs_to_update_profile?
    if @person.email.blank? ||
       @person.first_name.blank? ||
       @person.country_of_origin.blank? ||
       @person.gender.blank? ||
       @person.professional_background.blank? ||
       @person.include_in_mailings.nil? ||
       @person.invitation_to_mattermost.nil?
      return true
    end
  end
end
