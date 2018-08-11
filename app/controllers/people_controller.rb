class PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  after_action :restrict_people

  # GET /people
  # GET /people.xml
  def index
    authorize! :administrate, Person
    redirect_to all_people_path
  end

  def speakers
    authorize! :administrate, Person

    respond_to do |format|
      format.html do
        result = search Person.involved_in(@conference), params
        @people = result.paginate page: page_param
      end
      format.text do
        @people = Person.speaking_at(@conference).accessible_by(current_ability)
        render text: @people.map(&:email).join("\n")
      end
      result = search Person.involved_in(@conference), params
      @people = result.paginate page: page_param
      @csv_people = result

      format.csv  { send_data @csv_people.to_csv, filename: "speakers-#{Date.today}.csv" }
      format.xls { send_data @csv_people.to_csv(col_sep: "\t") }
    end
  end

  def confirmed_speakers
    authorize! :administrate, Person

    respond_to do |format|
      format.html do
        result = search Person.confirmed(@conference), params
        @people = result.paginate page: page_param
      end
      format.text do
        @people = Person.confirmed(@conference).accessible_by(current_ability)
        render text: @people.map(&:email).join("\n")
      end
      result = search Person.confirmed(@conference), params
      @people = result.paginate page: page_param
      @csv_people = result

      format.csv  { send_data @csv_people.to_csv, filename: "speakers-#{Date.today}.csv" }
      format.xls { send_data @csv_people.to_csv(col_sep: "\t") }
    end
  end

  def all
    authorize! :administrate, Person
    result = search Person, params
    @people = result.paginate page: page_param
    @csv_people = result

    respond_to do |format|
      format.html
      format.csv  { send_data @csv_people.to_csv, filename: "people-#{Date.today}.csv" }
      format.xls { send_data @csv_people.to_csv(col_sep: "\t") }
    end
  end

  def all_confirmed
    authorize! :administrate, Person
    result = Person.where(attendance_status: "confirmed")
    @people = result.paginate page: page_param

    respond_to do |format|
      format.html
    end
  end

  def dif
    authorize! :administrate, Person
    result = Person.joins(:dif)
    @people = result.paginate page: page_param
    @csv_people = result

    respond_to do |format|
      format.html
      format.csv  { send_data @csv_people.to_csv, filename: "dif-#{Date.today}.csv" }
      format.xls { send_data @csv_people.to_csv(col_sep: "\t") }
    end
  end

  def volunteers
    authorize! :administrate, Person
    result = Person.where(interested_in_volunteer: true)
    @people = result.paginate page: page_param
    @csv_people = result

    respond_to do |format|
      format.html
      format.csv  { send_data @csv_people.to_csv, filename: "volunteers-#{Date.today}.csv" }
      format.xls { send_data @csv_people.to_csv(col_sep: "\t") }
    end
  end

  def waitlisted
    authorize! :administrate, Person
    result = Person.where(attendance_status: "waitlist")
    @people = result.paginate page: page_param
    @csv_people = result
    respond_to do |format|
      format.html
      format.csv  { send_data @csv_people.to_csv, filename: "Waitlist-#{Date.today}.csv" }
    end
  end

  def canceled
    authorize! :administrate, Person
    result = Person.where(attendance_status: "canceled")
    @people = result.paginate page: page_param
    @csv_people = result
    respond_to do |format|
      format.html
      format.csv  { send_data @csv_people.to_csv, filename: "canceled-#{Date.today}.csv" }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    authorize! :read, @person
    @years_presented = person_presented_before?

    if @person.user.nil?
      @is_fellow = false
      @user = User.new
    else
      @user = @person.user
      if ConferenceUser.exists?(user_id: @user.id)
        @is_fellow = ConferenceUser.find_by(user_id: @user.id)
      else
        @is_fellow = false
      end
    end

    @current_events = @person.events_as_presenter_in(@conference)
    @other_events = @person.events_as_presenter_not_in(@conference)
    clean_events_attributes
    @availabilities = @person.availabilities.where("conference_id = #{@conference.id}")
    @expenses = @person.expenses.where(conference_id: @conference.id)
    @expenses_sum_reimbursed = @person.sum_of_expenses(@conference, true)
    @expenses_sum_non_reimbursed = @person.sum_of_expenses(@conference, false)

    @transport_needs = @person.transport_needs.where(:conference_id => @conference.id)

    respond_to do |format|
      format.html
      format.xml { render xml: @person }
      format.json { render json: @person }
    end
  end

  def feedbacks
    @person = Person.find(params[:id])
    authorize! :access, :event_feedback
    @current_events = @person.events_as_presenter_in(@conference)
    @other_events = @person.events_as_presenter_not_in(@conference)
  end

  def attend
    @person = Person.find(params[:id])
    @person.set_role_state(@conference, 'attending')
    redirect_to action: :show
  end

  # GET /people/new
  def new
    @person = Person.new
    authorize! :manage, @person

    respond_to do |format|
      format.html
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    if @person.nil?
      flash[:alert] = 'Not a valid person'
      return redirect_to action: :index
    end
    authorize! :manage, @person
  end

  # POST /people
  def create
    @person = Person.new(person_params)
    authorize! :manage, @person

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, notice: 'Person was successfully created.') }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /people/1
  def update
    @person = Person.find(params[:id])
    authorize! :manage, @person

    respond_to do |format|
      if @person.update_attributes(person_params)
        format.html { redirect_to(@person, notice: 'Person was successfully updated.') }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /people/1
  def destroy
    @person = Person.find(params[:id])
    authorize! :manage, @person
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(all_people_path) }
    end
  end

  def make_fellow
    @person = Person.find_by(id: params[:format])
    @conference = Conference.find_by(acronym: params[:conference_acronym])
    authorize! :manage, @person
    @user = User.find(@person.user_id)
    @user.update(role: "crew")
    con_user = ConferenceUser.new(conference_id: @conference.id, user_id: @person.user_id, role: "reviewer")
    if con_user.save
      redirect_to(person_path(@person.id), notice: 'Person was successfully updated to Fellow.')
    else
      redirect_to(person_path(@person.id), notice: 'Unsuccessful update!')
    end
  end

  def invite
    @person = Person.find_by(id: params[:format])
    authorize! :manage, @person
    if @person.update(attendance_status: "pending attendance")
      SelectionNotification.invite_notification(@person).deliver_now
      redirect_to(waitlisted_people_path, notice: 'Person was successfully invited, attendance status is now: pending attendance.')
    else
      redirect_to(waitlisted_people_path, notice: 'There was an error inviting the person. Check to see if they have fully registered.')
    end
  end

  def send_invitation
    authorize! :administrate, Person
    person = Person.find_by(id: params[:id])
    conference = Conference.find_by(acronym: params[:conference_acronym])
    InvitationMailer.invitation_mail(person, conference).deliver_now

    if Invited.exists?(person_id: person.id, conference_id: conference.id)
      redirect_to(person_path(person), alert: "This person was already invited but we've sent the invitation again.")
    else
      Invited.create!(person: person, conference: conference)

      redirect_to(person_path(person), notice: 'Person was invited.')
    end
  end

  def ticketing_form

  end

  def move_to_waitlist
    @person = Person.find_by(id: params[:format])
    authorize! :manage, @person
    if @person.update(attendance_status: 'waitlist')
      SelectionNotification.moved_to_waitlist_notification(@person).deliver_now
      redirect_to(all_people_path, notice: 'Person was successfully moved from pending attendance to the waitlist')
    else
      redirect_to(all_people_path, notice: 'There was an error moving the pending attendance person to the waitlist. They may not have updated all their registration requirements.')
    end
  end

  def allow_late_submissions
    @person = Person.find_by(id: params[:format])
    @conference = Conference.find_by(acronym: params[:conference_acronym])
    authorize! :manage, @person
    @user = User.find(@person.user_id)
    if @person.update(late_event_submit: true)
      redirect_to(person_path(@person.id), notice: 'Person was successfully updated to allow for late event submissions.')
    else
      redirect_to(person_path(@person.id), notice: 'Unsuccessful update!')
    end
  end

  def confirm_user
    @person = Person.find_by(id: params[:format])
    authorize! :manage, @person
    @user = User.find(@person.user_id)

    if @user.update(confirmed_at: Time.new)
      redirect_to(person_path(@person.id), notice: 'User profile has been confirmed.')
    else
      redirect_to(person_path(@person.id), notice: 'User profile WAS NOT confirmed.')
    end
  end

  def confirm_attendance
    @person = Person.find_by(id: params[:format])
    authorize! :manage, @person
    if @person.update(attendance_status: 'confirmed')
      flash[:sucess] = "#{@person.public_name} has been confirmed to attend the 2018 IFF!"
    else
      flash[:danger] = "#{@person.public_name} was not confirmed...they may need to complete their registration."
    end
    redirect_to(all_people_path)
  end

  def cancel_attendance
    @person = Person.find_by(id: params[:format])
    if @person.update(attendance_status: "canceled")
      return redirect_to(person_path(@person.id), notice: 'You canceled their attendance.')
    else
      return redirect_to(person_path(@person.id), notice: 'There was an error cancelling their attendance.')
    end
  end

  # will update a 'canceled' attendance status to 'pending attendance' status
  def move_to_pending
    @person = Person.find_by(id: params[:format])
    if @person.update(attendance_status: "pending attendance")
      return redirect_to(canceled_people_path, notice: 'Attendance updated to pending attendance.')
    else
      return redirect_to(canceled_people_path, notice: 'There was an error updating their attendance status.')
    end
  end

  def generate_confirmation_tokens
    users_to_generate_token = []
    users = User.where(confirm_attendance_token: nil)

    users.each do |user|
      if user.person && user.person.attendance_status == 'pending attendance'
        users_to_generate_token << user
      end
    end

    users_to_generate_token.each do |user|
      user.generate_confirm_attendance_token!
    end
    redirect_to root_path
  end


  private

  def restrict_people
    @people = @people.accessible_by(current_ability) unless @people.nil?
  end

  def search(people, params)
    if params.key?(:term) and not params[:term].empty?
      term = params[:term]
      sort = begin
               params[:q][:s]
             rescue
               nil
             end
      @search = people.ransack(first_name_cont: term,
                               last_name_cont: term,
                               public_name_cont: term,
                               email_cont: term,
                               abstract_cont: term,
                               description_cont: term,
                               user_email_cont: term,
                               m: 'or',
                               s: sort)
    else
      @search = people.ransack(params[:q])
    end

    @search.result(distinct: true)
  end

  def clean_events_attributes
    return if can? :crud, Event
    @current_events.map(&:clean_event_attributes!)
    @other_events.map(&:clean_event_attributes!)
  end

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :public_name, :email, :email_public, :gender, :avatar, :abstract, :description, :include_in_mailings, :note, :twitter, :personal_website,
      im_accounts_attributes: %i(id im_type im_address _destroy),
      languages_attributes: %i(id code _destroy),
      links_attributes: %i(id title url _destroy),
      phone_numbers_attributes: %i(id phone_type phone_number _destroy),
      ticket_attributes: %i(id remote_ticket_id)
    )
  end

  def person_presented_before?
    previous_events = []
    years_presented = []
    unless @person.events.empty?
      @person.events.each do |event|
        previous_events << event.iff_before
      end
    end
    unless previous_events.empty?
      previous_events.each do |event|
        if event.include?("2015") || event.include?("2016") || event.include?("2017")
          years_presented << event
        end
      end
    end
    years_presented
  end

end
