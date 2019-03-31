class AttendeeStats
  include StatsHelpers

  def initialize(conference)
    @conference = conference
  end

  def total_attendees
    @total_attendees ||= tickets.count
  end

  def new_attendees
    @new_attendees ||= tickets.where('iff_before LIKE ?', '%Not yet!%').count
  end

  def returning_attendees
    @returning_attendees ||= total_attendees - new_attendees
  end

  def total_requested_dif
    @total_requested_dif ||= Person.with_dif_requested(@conference).count
  end

  def total_pending_dif
    @total_pending_dif ||= Person.with_dif_pending(@conference).count
  end

  def total_granted_dif
    @total_granted_dif ||= Person.with_dif_granted(@conference).count
  end

  def total_volunteers
    @total_volunteers ||= tickets.where(interested_in_volunteer: true).count
  end

  def total_speakers
    @total_speakers ||= ticket_holders.involved_in(@conference).where(event_people: { event_role: EventPerson::SPEAKER }).count
  end

  def total_confirmed_speakers
    @total_confirmed_speakers ||= ticket_holders.speaking_at(@conference).count
  end

  def different_ticket_types
    @different_ticket_types ||= tickets.distinct.select(:ticket_option).count
  end

  def ticket_types_breakdown
    @ticket_types_breakdown ||= build_breakdown(tickets.group(:ticket_option).count, Ticket::OPTIONS)
  end

  def different_gender_options
    @different_gender_options ||= tickets.distinct.select(:gender_pronoun).count
  end

  def gender_options_breakdown
    @gender_options_breakdown ||= build_breakdown(tickets.group(:gender_pronoun).count, Person::GENDER_PRONOUN)
  end

  def different_countries_of_origin
    @different_countries_of_origin ||= ticket_holders.distinct.select(:country_of_origin).count
  end

  def countries_of_origin_breakdown
    @countries_of_origin_breakdown ||= build_breakdown(ticket_holders.group(:country_of_origin).count, Person::COUNTRIES)
  end

  def different_professional_backgrounds
    @different_professional_backgrounds ||= professional_backgrounds.uniq.size
  end

  def professional_backgrounds_breakdown
    @professional_backgrounds_breakdown ||= build_breakdown(professional_backgrounds.group_by(&:itself).transform_values(&:size), Person::PROFESSIONAL_BACKGROUND)
  end

  private

  def tickets
    @tickets ||= Ticket.where(status: Ticket::COMPLETED, conference: @conference)
  end

  def ticket_holders
    @ticket_holders ||= Person.with_ticket(@conference)
  end

  def professional_backgrounds
    @professional_backgrounds ||= ticket_holders.pluck(:professional_background).flatten.reject(&:blank?)
  end
end
