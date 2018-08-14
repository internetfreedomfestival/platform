class TicketingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_same_person
  before_action :require_invitation

  def ticketing_form
    @person = Person.find(params[:id])
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
end
