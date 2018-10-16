class TicketingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invitation, except: [:request_invitation]
  before_action :require_same_person, except: [:request_invitation]
  before_action :require_same_conference, except: [:request_invitation]
  before_action :no_previous_ticket, only: [:register_ticket]

  def ticketing_form
    @invited = Invited.find(params[:id])
    @person = Person.find_by(email: @invited.email)
    @conference = @invited.conference
    @ticket = Ticket.new(conference: @conference, person: @person)
  end

  def register_ticket
    @invited = Invited.find(params[:id])
    @person = Person.find_by(email: @invited.email)
    @conference = @invited.conference

    @ticket = Ticket.new(ticket_params.merge(conference: @conference, person: @person))

    @ticket.iff_before = ticket_params["iff_before"]
    @ticket.iff_goals = ticket_params["iff_goals"]
    @ticket.iff_days = ticket_params["iff_days"]

    unless @ticket.save
      render 'ticketing_form'
      return
    end

    if !AttendanceStatus.find_by(person: @person, conference: @conference)
      AttendanceStatus.create!(person: @person, conference: @conference, status: AttendanceStatus::REGISTERED)
    else
      status = AttendanceStatus.find_by(person: @person, conference: @conference)
      status.status = AttendanceStatus::REGISTERED
      status.save
    end

    TicketingMailer.ticketing_mail(@ticket, @person, @conference).deliver_now

    redirect_to cfp_root_path, notice: "You've been succesfully registered"
  end


  private


  def ticket_params
    ticket = params.require(:ticket).permit(:public_name,
                                   :gender_pronoun,
                                   {iff_before: []},
                                   {iff_goals: []},
                                   :interested_in_volunteer,
                                   {iff_days: []},
                                   :code_of_conduct
    )
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

    if AttendanceStatus.exists?(
        person_id: person.id,
        conference_id: conference.id,
        status: AttendanceStatus::REGISTERED
      )
      flash[:error] = 'You cannot register to the conference twice'
      redirect_to cfp_root_path
    end
  end
end
