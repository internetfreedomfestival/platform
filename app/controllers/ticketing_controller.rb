class TicketingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invitation
  before_action :require_same_person
  before_action :require_same_conference

  before_action :no_previous_ticket, only: [:register_ticket]

  def ticketing_form
    @invited = Invited.find(params[:id])
    @person = Person.find_by(email: @invited.email)
    @conference = @invited.conference
  end

  def register_ticket
    attributes = params[:person]

    @invited = Invited.find(params[:id])
    @person = Person.find_by(email: @invited.email)
    @conference = @invited.conference

    @person.public_name = attributes['public_name']
    @person.gender_pronoun = attributes['gender_pronoun']
    @person.iff_before = attributes['iff_before']
    @person.iff_goals = attributes['iff_goals']
    @person.interested_in_volunteer = attributes['interested_in_volunteer']
    @person.iff_days = attributes['iff_days']

    errors = validate_required_ticket_fields(attributes)
    unless errors.empty?
      flash[:error] = "You cannot get a ticket without #{errors.join(', ')}"
      render 'ticketing_form'
      return
    end

    @person.save!

    Attendee.create(person: @person, conference: @conference, status: 'invited')

    TicketingMailer.ticketing_mail(@person, @conference).deliver_now

    redirect_to cfp_root_path, notice: "You've been succesfully registered"
  end

  private

  REQUIRED_FIELDS = {
    public_name: 'public name',
    gender_pronoun: 'gender pronoun',
    iff_before: 'past editions',
    iff_goals: 'goals',
    iff_days: 'attendance days',
    code_of_conduct: 'code of conduct'
  }

  def validate_required_ticket_fields(values)
    errors = []

    REQUIRED_FIELDS.each do |field, error|
      value = values[field]

      if value.nil? || value.blank?
        errors << error
      end
    end

    errors
  end

  def check_invitation
    unless Invited.exists?(id: params[:id])
      flash[:error] = 'You cannot register to the conference without a valid invitation'
      redirect_to cfp_root_path
    end
  end

  def require_same_person
    invited = Invited.find(params[:id])
    email = invited.email

    if current_user.person.nil? || email != current_user.person.email
      flash[:error] = 'You cannot register to the conference without a valid invitation'
      redirect_to cfp_root_path
    end
  end

  def require_same_conference
    invited = Invited.find(params[:id])
    conference = Conference.find_by(acronym: params[:conference_acronym])

    unless invited.conference.acronym == conference.acronym
      flash[:error] = 'You cannot register to the conference without an invitation'
      redirect_to cfp_root_path
    end
  end

  def no_previous_ticket
    invited = Invited.find(params[:id])

    person = Person.find_by(email: invited.email)
    conference = invited.conference

    if Attendee.exists?(person_id: person.id, conference_id: conference.id)
      flash[:error] = 'You cannot register to the conference twice'
      redirect_to cfp_root_path
    end
  end
end
