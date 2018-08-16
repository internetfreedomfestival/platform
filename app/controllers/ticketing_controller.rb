class TicketingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_same_person
  before_action :require_invitation

  before_action :no_previous_ticket, only: [:register_ticket]

  def ticketing_form
    @person = Person.find(params[:id])
  end

  def register_ticket
    id = params[:id]
    attributes = params[:person]

    @person = Person.find(id)
    @person.public_name = attributes[:public_name]
    @person.gender_pronoun = attributes[:gender_pronoun]
    @person.iff_before = attributes[:iff_before]
    @person.iff_goals = attributes[:iff_goals]
    @person.interested_in_volunteer = attributes[:interested_in_volunteer]
    @person.iff_days = attributes[:iff_days]

    @person.attendance_status = 'confirmed'

    unless @person.save
      render :ticketing_form, errors: @person.errors
    else
      redirect_to cfp_root_path, notice: "You've been succesfuly registered"
    end
  end

  private

  def require_same_person
    person = Person.find(params[:id])

    if current_user.person.nil? || person.id != current_user.person.id
      flash[:error] = 'You cannot register to the conference without a valid invitation'
      redirect_to cfp_root_path
    end
  end

  def require_invitation
    person = Person.find(params[:id])
    conference = Conference.find_by(acronym: params[:conference_acronym])

    unless Invited.exists?(person_id: person.id, conference_id: conference.id)
      flash[:error] = 'You cannot register to the conference without an invitation'
      redirect_to cfp_root_path
    end
  end

  def no_previous_ticket
    person = Person.find(params[:id])

    if person.attendance_status == 'confirmed'
      flash[:error] = 'You cannot register to the conference twice'
      redirect_to cfp_root_path
    end
  end
end
