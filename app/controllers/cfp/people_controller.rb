class Cfp::PeopleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :check_cfp_open

  def show
    @person = current_user.person
    @not_registered = (@person.public_name == "Enter a public name here")
    @no_events = @person.events.empty?
    @no_dif = @person.dif.nil?
    @is_fellow = ConferenceUser.exists?(user_id: current_user.id)

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
    @person = current_user.person
    if @person.public_name == 'Enter a public name here'
      @first_time = true
    end
    if @person.nil?
      flash[:alert] = 'Not a valid person'
      return redirect_to action: :index
    end
  end

  def create
    @person = current_user.person
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
    @person = current_user.person
   # validates that public name hasn't already been taken
    email = person_params[:email] && person_params[:email_confirm]
    if email == ""
      flash[:danger] = "Confirm your email"
      return redirect_to action: :edit
    elsif email != @person.email && Person.where(email: email).count > 0
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
    @person = current_user.person
    if @person.update(attendance_status: "canceled")
      flash[:alert] = "You have canceled your attendance."
      return redirect_to action: :show
    else
      flash[:alert] = "There was an error cancelling your attendance. Please contact the IFF team."
      return redirect_to action: :show
    end
  end

  def confirm_attendance
    @person = current_user.person
    if @person.update(attendance_status: "confirmed")
      flash[:success] = "You are confirmed to attend the 2018 IFF!"
    else
      flash[:alert] = "There was some issue updating your status. Please contact the IFF team."
    end
    return redirect_to action: :show
  end
  private

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_confirm, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :include_in_mailings, :pgp_key, :country_of_origin, :other_background, :organization, :project, :title, :invitation_to_mattermost, :iff_goals, :challenges, :other_resources, :interested_in_volunteer, :already_mattermost, :already_mailing, :twitter, :personal_website, :complete_mattermost, :complete_mailing, { iff_before: [] }, { professional_background: [] },
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
    )
  end

  def person_invalid_for_update
    if  person_params[:email].nil? ||
        person_params[:email_confirm].nil? || person_params[:email] != person_params[:email_confirm] ||
        person_params[:first_name] == "" ||
        person_params[:country_of_origin] == "" ||
        person_params[:gender] == "" ||
        person_params[:professional_background].nil? ||
        person_params[:include_in_mailings] == [] ||
        person_params[:invitation_to_mattermost] == []
      return true
    end
  end
end
