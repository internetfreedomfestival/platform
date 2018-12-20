class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def index
    return redirect_to new_conference_path if Conference.count.zero?
    return redirect_to cannot_read_redirect_path if cannot? :read, Conference
    return redirect_to deleted_conference_redirect_path if @conference.nil?

    @person_with_country = Person.all.map(&:country_of_origin)
    @professional_background_of_people = Person.joins(:tickets).where(tickets: {status: "Completed"}).map(&:professional_background)
    @tickets_all = Ticket.all
    @people_with_tickets_completed = Person.joins(:tickets).where(tickets: {status: "Completed"})
    @people_with_ticket_and_be_speaker = Person.joins(:tickets, :event_people).where(tickets: {status: "Completed"}).where(event_people: {event_role: "speaker"})
    @people_with_event = Person.joins(:event_people).where(event_people: {event_role: "speaker"})
    @tickets_with_gender = Ticket.all.map(&:gender_pronoun)
    @total_tickets_amount = Ticket.all.map(&:amount)
    @new_attendees_tickets = Ticket.where('iff_before LIKE "%Not yet!%"')
    @returning_attendees_tickets = Ticket.where.not('iff_before LIKE "%Not yet!%"')
    @statistics_gender = Hash.new
    @statistics_country = Hash.new
    @statistics_roles = Hash.new
    @statistics_speakers = Hash.new
    @statistics_professional_background = Hash.new
    @pronouns = Person::GENDER_PRONOUN
    @professional_background = Person::PROFESSIONAL_BACKGROUND
    # @open_schedule = true
    @person = Person.find_by(user_id: current_user.id)
    @versions = PaperTrail::Version.where(conference_id: @conference.id).includes(:item).order('created_at DESC').limit(5)
    respond_to do |format|
      format.html
    end
  end

  private

  def users_last_conference_path
    conference_home_path(conference_acronym: current_user.last_conference.acronym)
  end

  # maybe conference got deleted
  def deleted_conference_redirect_path
    return users_last_conference_path if current_user.last_conference
    new_conference_path
  end

  # maybe a crew user tries to login to the wrong conference?
  def cannot_read_redirect_path
    if current_user.is_crew?
      return users_last_conference_path if current_user.last_conference
    end
    cfp_root_path
  end
end
