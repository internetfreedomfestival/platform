class ChargesController < ApplicationController
  def new
    @ticket = Ticket.find(params[:ticket_id])
    @amount_in_cents = @ticket.amount * 100
    @invited = Invited.find(params[:id])
    @conference = @invited.conference
  end

  def create
    @ticket = Ticket.find(params[:ticket_id])
    @amount_in_cents = @ticket.amount * 100
    @invited = Invited.find(params[:id])

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount_in_cents,
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
      redirect_to cfp_root_path, notice: "Success: Your IFF Ticket has been issued!"
    else
      redirect_to new_charge_path(@invited, @ticket)
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path(@invited, @ticket)
  end
end
