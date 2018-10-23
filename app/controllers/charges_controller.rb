class ChargesController < ApplicationController
  def new
    @ticket = Ticket.where(person_id: current_user.person.id).last
    @amount = Ticket.where(person_id: current_user.person.id).last.amount
    @invited = Invited.find_by(person_id: current_user.person.id)
    @conference = @invited.conference
    #id ticket por url, buscar ^ por id ticket
  end

  def create
    # Amount in cents
    @ticket = Ticket.find_by(person_id: current_user.person.id)
    @amount = @ticket.amount

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'usd'
    )

  @ticket.update(status: "completed")

  if charge.status == "succeeded"
    if !AttendanceStatus.find_by(person: @ticket.person, conference: @ticket.conference)
      AttendanceStatus.create!(person: @ticket.person, conference: @ticket.conference, status: AttendanceStatus::REGISTERED)
    else
      status = AttendanceStatus.find_by(person: @ticket.person, conference: @ticket.conference)
      status.status = AttendanceStatus::REGISTERED
      status.save
    end

    TicketingMailer.ticketing_mail(@ticket, @ticket.person, @ticket.conference).deliver_now
    redirect_to cfp_root_path, notice: "Thanks, you've been succesfully registered"
    else
      redirect_to new_charge_path
  end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end
