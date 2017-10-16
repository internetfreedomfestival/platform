class Cfp::PeopleController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!
  before_action :check_cfp_open

  def show
    @person = current_user.person
    @person.public_name == "Enter a public name here" ? @not_registered = true : @not_registered =false
    @person.events.count > 0 ? @no_events = false : @no_events = true
    @person.dif.nil? ? @no_dif = true : @no_dif = false
    ConferenceUser.exists?(user_id: current_user.id) ? @is_fellow = true : @is_fellow = false
    
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
    pub_name = person_params[:public_name]
    if pub_name == "Enter a public name here"
      flash[:danger] = "This public name has already been taken!"
      return redirect_to action: :edit
    elsif pub_name != @person.public_name && Person.where(public_name: pub_name).count > 0
      flash[:danger] = "This public name has already been taken!"
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

  private

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :include_in_mailings, :pgp_key, :country_of_origin, :other_background, :organization, :project, :title, :invitation_to_mattermost, :iff_goals, :challenges, :other_resources, :interested_in_volunteer, :already_mattermost, :already_mailing, :twitter, :personal_website, { iff_before: [] }, { professional_background: [] },
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
    )
  end

  def person_invalid_for_update
    if person_params[:email].nil? || person_params[:email] == person_params[:public_name] || person_params[:professional_background].length < 2 || person_params[:professional_background].nil? || person_params[:country_of_origin].nil? || person_params[:iff_before].length < 2 || person_params[:iff_before].nil? || person_params[:gender].nil?
      return true
    end
  end
end
