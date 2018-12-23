class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invitation, except:[:refund_ticket]
  before_action :require_same_person, except:[:refund_ticket]
  before_action :require_same_conference, except:[:refund_ticket]
  before_action :no_previous_ticket, only: [:register_ticket]

  def ticketing_form
    @invite = Invite.find(params[:id])
    @person = Person.find_by(email: @invite.email)
    @conference = @invite.conference
    @ticket = Ticket.new(conference: @conference, person: @person)
  end

  def view_ticket
    @person = Person.find_by(id: current_user.person)
    @invite = Invite.find(params[:id])
    @conference = @invite.conference
    @ticket = Ticket.find_by(person: @person, conference: @conference, status: "Completed")
  end

  def cancel_ticket
    @person = Person.find_by(id: current_user.person)
    @invite = Invite.find(params[:id])
    @conference = @invite.conference
    @ticket = Ticket.find_by(person: @person, conference: @conference, status: "Completed")

    if @ticket.amount == 0
      @ticket.update(status: "Canceled")
    else
      @ticket.update(status: "To Refund")
    end

    status = AttendanceStatus.find_by(person: @person, conference: @conference)
    status.status = AttendanceStatus::INVITED
    status.save

    redirect_to cfp_root_path, notice: "You have canceled your ticket"
  end

  def refund_ticket
    authorize! :administrate, Person

    @ticket = Ticket.find(params[:id])
    @ticket.update(status: "Canceled")

    redirect_to(tickets_people_path, alert: "This ticket has been canceled")
  end

  def send_ticket
    @person = Person.find_by(id: current_user.person)
    @invite = Invite.find(params[:id])
    @conference = @invite.conference
    @ticket = Ticket.find_by(person: @person, conference: @conference)
    TicketingMailer.ticketing_mail(@ticket, @person, @conference).deliver_now
    redirect_to view_ticket_path, notice: "Succesfully resent. Check your email."
  end

  def register_ticket
    @invite = Invite.find(params[:id])
    @person = Person.find_by(email: @invite.email)
    @conference = @invite.conference

    if Ticket.exists?(conference: @conference, person: @person, status: "Pending")
      @ticket = Ticket.find_by(conference: @conference, person: @person, status: "Pending")
    else
      @ticket = Ticket.new(ticket_params.merge(conference: @conference, person: @person))
      @ticket.status = "Pending"
    end


    success = if @ticket.persisted?
      @ticket.update(ticket_params.merge(status: "Pending"))
    else
      @ticket.save
    end

    unless success
      render 'ticketing_form'
      return
    end

    if ticket_params["amount"] != "0"
      return redirect_to new_charge_path(@invite, @ticket)
    end

    if !AttendanceStatus.find_by(person: @person, conference: @conference)
      AttendanceStatus.create!(person: @person, conference: @conference, status: AttendanceStatus::REGISTERED)
    else
      status = AttendanceStatus.find_by(person: @person, conference: @conference)
      status.status = AttendanceStatus::REGISTERED
      status.save
    end
    @ticket.update(status: "Completed")
    TicketingMailer.ticketing_mail(@ticket, @person, @conference).deliver_now
    redirect_to cfp_root_path, notice: "Success: Your IFF Ticket has been issued!"
  end

  def create
    if not @conference.ticket_server_enabled? or @conference.ticket_server.nil?
      return redirect_to edit_conference_path(conference_acronym: @conference.acronym), alert: 'No ticket server configured'
    end

    server = @conference.ticket_server

    if params.key?(:event_id)
      @event = Event.find(params[:event_id])
      authorize! :crud, @event

      begin
        title = t(:your_submission, locale: @event.language) + " " + @event.title.truncate(30)
        remote_id = server.create_remote_ticket(title: title,
                                                requestors: server.create_ticket_requestors(@event.speakers),
                                                owner_email: current_user.email,
                                                frab_url: event_url(@event),
                                                test_only: params[:test_only])
      rescue => ex
        return redirect_to event_path(id: params[:event_id], method: :get), alert: "Failed to create ticket: #{ex.message}"
      end

      if remote_id.nil?
        return redirect_to event_path(id: params[:event_id], method: :get), alert: 'Failed to receive remote id'
      end

      @event.ticket = Ticket.new if @event.ticket.nil?
      @event.ticket.remote_ticket_id = remote_id
      @event.save
      redirect_to event_path(id: params[:event_id], method: :get)
    end

    if params.key?(:person_id)
      @person = Person.find(params[:person_id])
      authorize! :crud, @person

      begin
        remote_id = server.create_remote_ticket(title: @person.full_name,
                                                requestors: @person.email,
                                                owner_email: current_user.email,
                                                frab_url: person_url(@person),
                                                test_only: params[:test_only])
      rescue => ex
        return redirect_to person_path(id: params[:person_id], method: :get), alert: "Failed to create ticket: #{ex.message}"
      end

      if remote_id.nil?
        return redirect_to person_path(id: params[:person_id], method: :get), alert: 'Failed to receive remote id'
      end

      @person.ticket = Ticket.new if @person.ticket.nil?
      @person.ticket.remote_ticket_id = remote_id
      @person.save
      redirect_to person_path(id: params[:person_id], method: :get)
    end
  end

  private

  def ticket_params
    ticket = params.require(:ticket).permit(:public_name,
                                   :gender_pronoun,
                                   {iff_before: []},
                                   {iff_goals: []},
                                   :interested_in_volunteer,
                                   {iff_days: []},
                                   :code_of_conduct,
                                   :ticket_option,
                                   :amount,
    )
  end

  def check_invitation
    unless Invite.exists?(id: params[:id])
      flash[:error] = 'You cannot register to the conference without a valid invitation'
      redirect_to cfp_root_path
    end
  end

  def require_same_person
    invite = Invite.find(params[:id])
    email = invite.email

    if current_user.person.nil? || email != current_user.person.email
      flash[:error] = 'You cannot register to the conference without a valid invitation'
      redirect_to cfp_root_path
    end
  end

  def require_same_conference
    invite = Invite.find(params[:id])
    conference = Conference.find_by(acronym: params[:conference_acronym])
    unless invite.conference.acronym == conference.acronym
      flash[:error] = 'You cannot register to the conference without an invitation'
      redirect_to cfp_root_path
    end
  end

  def no_previous_ticket
    invite = Invite.find(params[:id])

    person = Person.find_by(email: invite.email)
    conference = invite.conference

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
