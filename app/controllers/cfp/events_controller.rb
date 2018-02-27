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
  def new
    @new = true
    @public_names = ""
    Person.all.each do |person|
      @public_names += person.public_name + ", " unless person.public_name == "Enter a public name here"
    end
    @users = User.all
    person = Person.find_by(user_id: current_user.id)
    if auth_person_for_new_event?(person)
      return redirect_to cfp_person_path, flash: { error: t('cfp.complete_personal_profile') }
    end

    # Remove this if statement for next conference. It is for submiting events after the conference deadline
    if person.attendance_status == "confirmed"
      authorize! :submit, Event
      @event = Event.new(time_slots: @conference.default_timeslots)
      @event.recording_license = @conference.default_recording_license

      return respond_to do |format|
        format.html # new.html.erb
      end
    elsif person.late_event_submit == false
      return redirect_to cfp_person_path, flash: { error: t('cfp.events_closed') }
    end
    authorize! :submit, Event
    @event = Event.new(time_slots: @conference.default_timeslots)
    @event.recording_license = @conference.default_recording_license

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /cfp/events/1/edit
  def edit
    @edit = true
    @public_names = ""
    Person.all.each do |person|
      @public_names += person.public_name + ", "
    end
    authorize! :submit, Event
    @event = current_user.person.events.find(params[:id])
  end

  # POST /cfp/events
  def create
    authorize! :submit, Event
    @event = Event.new(event_params.merge(recording_license: @conference.default_recording_license))
    @event.conference = @conference
    @event.event_people << EventPerson.new(person: current_user.person, event_role: 'submitter')
    @event.event_people << EventPerson.new(person: current_user.person, event_role: 'speaker')

    respond_to do |format|
      if @event.save
        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_created_notice')) }
      else
        flash[:alert] = "You must fill out all the required fields!"
        @new = true
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /cfp/events/1
  def update
    authorize! :submit, Event
    @event = current_user.person.events.readonly(false).find(params[:id])
    @event.recording_license = @event.conference.default_recording_license unless @event.recording_license

    # Removes extra spaces saved by params and does not update for [""] params 
    # years_only = keep_old_iff_before_if_blank

    respond_to do |format|
      if @event.update_attributes(event_params)
        # @event.update(iff_before: years_only)
        format.html { redirect_to(cfp_person_path, notice: t('cfp.event_updated_notice')) }
      else
        flash[:alert] = "You must fill out all the required fields!"
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
end
