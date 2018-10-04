class Cfp::EventsController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!, except: :confirm


  # GET /cfp/events
  # GET /cfp/events.xml
  def index
    authorize! :submit, Event

    @events = current_user.person.events
    @events.map(&:clean_event_attributes!) unless @events.nil?

    respond_to do |format|
      format.html { redirect_to cfp_person_path }
      format.xml  { render xml: @events }
    end
  end

  # GET /cfp/events/1
  def show
    authorize! :submit, Event
    redirect_to(edit_cfp_event_path)
  end

  # GET /cfp/events/new
  # def new
  #   @new = true
  #
  #   @users = User.all
  #   person = Person.find_by(user_id: current_user.id)
  #   if auth_person_for_new_event?(person)
  #     return redirect_to cfp_person_path, flash: { error: t('cfp.complete_personal_profile') }
  #   end
  #
  #   # Remove this if statement for next conference. It is for submiting events after the conference deadline
  #   if person.old_attendance_status == "confirmed"
  #     authorize! :submit, Event
  #     @event = Event.new(time_slots: @conference.default_timeslots)
  #     @event.recording_license = @conference.default_recording_license
  #
  #     return respond_to do |format|
  #       format.html # new.html.erb
  #     end
  #   elsif person.late_event_submit == false
  #     return redirect_to cfp_person_path, flash: { error: t('cfp.events_closed') }
  #   end
  #   authorize! :submit, Event
  #   @event = Event.new(time_slots: @conference.default_timeslots)
  #   @event.recording_license = @conference.default_recording_license
  #
  #   respond_to do |format|
  #     format.html # new.html.erb
  #   end
  # end

  def new
    authorize! :submit, Event
    @new = true
    @users = User.all

    @person = Person.find_by(user_id: current_user.id)

    @event = Event.new(time_slots: @conference.default_timeslots)
    @event.recording_license = @conference.default_recording_license
  end

  # GET /cfp/events/1/edit
  def edit
    authorize! :submit, Event
    @edit = true
    @event = current_user.person.events.find(params[:id])

  end

  # POST /cfp/events
  def create
    authorize! :submit, Event

    event_values = prepare_params(form_params)
    event_values[:other_presenters] = remove_duplicates_of_other_presenters_list(event_values[:other_presenters])
    @event = build_event(event_values)

    duplicated_title = duplicated_title?(@event.title)
    valid_presenters = !invalid_presenters?(@event.other_presenters)

    instructions_checked = event_values[:instructions] == 'true'
    code_of_conduct_checked = event_values[:code_of_conduct] == 'true'
    understand_one_presenter_checked = event_values[:understand_one_presenter] == 'true'
    confirm_not_stipend_checked = event_values[:confirm_not_stipend] == 'true'
    travel_assistance_checked = event_values[:travel_assistance] == 'true' || event_values[:travel_assistance] == "1"
    travel_assistance = travel_assistance_checked == false || (travel_assistance_checked == true && understand_one_presenter_checked && confirm_not_stipend_checked)

    event_valid = @event.valid? && valid_presenters && instructions_checked && code_of_conduct_checked && !duplicated_title && travel_assistance
    emails_list = valid_presenters(@event.other_presenters)

    respond_to do |format|
      if event_valid && @event.save
        EventPerson.create(person: current_user.person, event: @event, event_role: 'submitter')
        EventsMailer.create_event_mail(current_user.person.email, @event).deliver_now

        emails_list.map do |email|
          EventPerson.create(person: Person.find_by(email: email), event: @event, event_role: 'collaborator')
          EventsMailer.create_event_mail(email, @event).deliver_now
        end

        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_created_notice')) }
      else

        flash[:alert] = "You must fill out all the required fields!"

        if event_values[:instructions] == nil
          @event.errors.messages[:instructions] = ["can't be blank"]
        end

        if event_values[:understand_one_presenter] == nil
          @event.errors.messages[:understand_one_presenter] = ["can't be blank"]
        end

        if event_values[:confirm_not_stipend] == nil
          @event.errors.messages[:confirm_not_stipend] = ["can't be blank"]
        end

        if event_values[:code_of_conduct] == nil
          @event.errors.messages[:code_of_conduct] = ["can't be blank"]
        end

        flash[:danger] = []

        if duplicated_title
          flash[:danger] << "There is already a session submitted with this title. Please review your title and make sure that your session is not already submitted."
        end

        if invalid_presenters?(@event.other_presenters)
          @invalid_list_of_emails = invalid_presenters_list(@event.other_presenters)
          wrong_emails_alert = "These emails does not exist in our database: " << @invalid_list_of_emails << ". Please, correct this. Remember emails can be separated by , or space."
          flash[:danger] <<  wrong_emails_alert
          flash[:danger] << "It seems that the e-mail you inserted does not exist in our database. Please be sure your colleagues are registered platform users in order to be able to add them as your collaborators.
                            NOTE: This field is not mandatory and therefore you can add information about your collaborators later."
        end
        @form_params = form_params
        @new = true

        format.html { render action: 'new' }
      end
    end
  end

  # PUT /cfp/events/1
  def update
    authorize! :submit, Event
    event_values = prepare_params(form_params)
    event_values[:other_presenters] = remove_duplicates_of_other_presenters_list(event_values[:other_presenters])

    @event = current_user.person.events.readonly(false).find(params[:id])
    old_emails_list = @event.other_presenters

    valid_presenters = !invalid_presenters?(event_values[:other_presenters])

    instructions_checked = event_values[:instructions] == 'true'
    code_of_conduct_checked = event_values[:code_of_conduct] == 'true'
    understand_one_presenter_checked = event_values[:understand_one_presenter] == 'true'
    confirm_not_stipend_checked = event_values[:confirm_not_stipend] == 'true'
    travel_assistance_checked = event_values[:travel_assistance] == 'true'
    travel_assistance = travel_assistance_checked == false || (travel_assistance_checked == true && understand_one_presenter_checked && confirm_not_stipend_checked)

    event_valid = valid_presenters && instructions_checked && code_of_conduct_checked && travel_assistance

    respond_to do |format|
      if @event.update(event_values) && event_valid
        emails_list = valid_presenters(event_values[:other_presenters])
        create_role_if_not_exists(emails_list, @event)
        new_emails_list = @event.other_presenters
        delete_role(old_emails_list, new_emails_list, @event)

        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_updated_notice')) }
      else
        flash[:alert] = "You must fill out all the required fields!"

        if event_values[:instructions] == nil
          @event.errors.messages[:instructions] = ["can't be blank"]
        end

        if event_values[:understand_one_presenter] == nil
          @event.errors.messages[:understand_one_presenter] = ["can't be blank"]
        end

        if event_values[:confirm_not_stipend] == nil
          @event.errors.messages[:confirm_not_stipend] = ["can't be blank"]
        end

        if event_values[:code_of_conduct] == nil
          @event.errors.messages[:code_of_conduct] = ["can't be blank"]
        end

        flash[:danger] = []

        if @event.errors.messages[:title]
          flash[:danger] << "There is already a session submitted with this title. Please review your title and make sure that your session is not already submitted."
        end

        if invalid_presenters?(event_values[:other_presenters])
          @invalid_list_of_emails = invalid_presenters_list(event_values[:other_presenters])
          wrong_emails_alert = "These emails does not exist in our database: " << @invalid_list_of_emails << ". Please, correct this. Remember emails can be separated by , or space."
          flash[:danger] <<  wrong_emails_alert
          flash[:danger] << "It seems that the e-mail you inserted does not exist in our database. Please be sure your colleagues are registered platform users in order to be able to add them as your collaborators.
                            NOTE: This field is not mandatory and therefore you can add information about your collaborators later."
        end
        @edit = true

        format.html { render action: 'edit' }
      end
    end
  end

  def update_state
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id])
    respond_to do |format|
      if @event.update(state: "confirmed")
        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_updated_notice')) }
      else
        flash[:alert] = "An error occured, please contact the IFF staff."
        format.html { render action: 'show' }
      end
    end
  end

  # Delete /cfp/events/1
  def destroy
    authorize! :submit, Event
    event = current_user.person.events.readonly(false).find(params[:id])

    respond_to do |format|
      if event.delete
        if current_user.person.events.empty? && current_user.person.dif
          current_user.person.dif.delete
        end
        format.html { redirect_to(cfp_person_path, notice: "Your proposal: '#{event.title}' has been deleted") }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def withdraw
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id], readonly: false)
    @event.withdraw!
    redirect_to(cfp_person_path, notice: t('cfp.event_withdrawn_notice'))
  end

  def confirm
    if params[:token]
      event_person = EventPerson.find_by_confirmation_token(params[:token])
      # Catch undefined method `person' for nil:NilClass exception if no confirmation token is found.
      if event_person.nil?
        return redirect_to cfp_root_path, flash: { error: t('cfp.no_confirmation_token') }
      end

      event_people = event_person.person.event_people.where(event_id: params[:id])
      login_as(event_person.person.user) if event_person.person.user
    else
      fail 'Unauthenticated' unless current_user
      event_people = current_user.person.event_people.where(event_id: params[:id])
    end
    if event_people.each(&:confirm!)
      event = Event.find(params[:id])
      event.update(etherpad_url: "pad.internetfreedomfestival.org/p/#{event.id}")
    end
    if current_user
      redirect_to cfp_person_path, notice: t('cfp.thanks_for_confirmation')
    else
      render layout: 'signup'
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :subtitle, :event_type, :time_slots, :language, :abstract, :description, :logo, :track_id, :submission_note, :tech_rider, :target_audience_experience, :desired_outcome, :skill_level, :iff_before, :travel_assistance, :other_presenters, :public_type, { iff_before: [] }, :track,
      event_attachments_attributes: %i(id title attachment public _destroy),
      links_attributes: %i(id title url _destroy)
    )
  end

  def form_params
    params.require(:event).permit(:title, :subtitle, :other_presenters, :description, :public_type,
      :desired_outcome, :phone_number, :track_id, :event_type,
      :projector, {iff_before: []}, :instructions, :travel_assistance, :group,
      :recipient_travel_stipend, {travel_support: []}, {past_travel_assistance: []},
      :understand_one_presenter, :confirm_not_stipend, :code_of_conduct)
  end

  def prepare_params(form_params)
    event_values = form_params.merge(
      recording_license: @conference.default_recording_license,
    )
    event_values[:iff_before] = event_values[:iff_before].reject { |value| value.blank? }
    event_values[:iff_before] = nil if event_values[:iff_before].empty?
    event_values[:travel_support] = event_values[:travel_support].reject { |value| value.blank? }
    event_values[:travel_support] = nil if event_values[:travel_support].empty?
    event_values[:past_travel_assistance] = event_values[:past_travel_assistance].reject { |value| value.blank? }
    event_values[:past_travel_assistance] = nil if event_values[:past_travel_assistance].empty?

    event_values
  end

  def build_event(event_values)
    event = Event.new(event_values)
    event.instructions = event_values[:instructions]
    if event.track == 'Workshop'
      event.time_slots = 6
    else
      event.time_slots = 3
    end
    event.conference = @conference
    event.event_people << EventPerson.new(person: current_user.person, event_role: 'speaker')
    event
  end

  def create_role_if_not_exists(emails_list, event)
    emails_list.map do |email|
      if EventPerson.find_by(person: Person.find_by(email: email), event: event, event_role: 'collaborator').nil?
          EventPerson.create(person: Person.find_by(email: email), event: event, event_role: 'collaborator')
          EventsMailer.create_event_mail(email, event).deliver_now
      end
    end
  end

  def remove_duplicates_of_other_presenters_list(list)
    list.split(/[\s,]/).reject { |c| c.empty? }.uniq.join(',')
  end

  def delete_role(old_emails_list, new_emails_list, event)
    emails_to_delete = old_emails_list.split(/[\s,]/) - new_emails_list.split(/[\s,]/)

    emails_to_delete.map do |email|
      Rails.logger.info "deleting email #{email}"
      person = EventPerson.find_by(person: Person.find_by(email: email), event: event, event_role: 'collaborator')
      person.destroy if person
    end
  end

  def valid_presenters(presenters)
    email_list = presenters.split(/[\s,]/)

    email_list.select do |email|
      Person.find_by(email: email)
    end
  end

  def invalid_presenters?(presenters)
    return false if presenters.nil? || presenters.blank?

    email_list = presenters.split(/[\s,]/)

    email_list.each do |email|
      found = Person.find_by(email: email)
      if !found
        return true
      end
    end
    false
  end

  def invalid_presenters_list(presenters)
    return [] if presenters.nil? || presenters.blank?

    invalid_list_of_emails = []
    email_list = presenters.split(/[\s,]/)
    email_list.each do |email|
      found = Person.find_by(email: email)
      if found.nil?
        invalid_list_of_emails << email
      end
    end

    return invalid_list_of_emails.reject(&:blank?).join(", ")
  end

  def duplicated_title?(title)
    Event.exists?(title: title, conference: @conference)
  end

  def auth_person_for_new_event?(person)
    !person.valid? || person.professional_background == [""] || person.iff_before == [""] || person.country_of_origin.nil?
  end

  def keep_old_iff_before_if_blank
    years_only = []
    if params[:event][:iff_before] == [""]
      years_only = @event.iff_before
    else
      params[:event][:iff_before].each do |year|
        years_only << year unless year == ""
      end
    end
    years_only
  end

  def keep_old_travel_support_if_blank
    support = []
    if params[:event][:travel_support] == [""]
      support = @event.travel_support
    else
      params[:event][:travel_support].each do |s|
        support << s unless s == ""
      end
    end
    support
  end
end
