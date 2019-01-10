class TicketingMailer < ApplicationMailer
  def ticketing_mail(ticket, person, conference)
    @first_name = person.first_name
    @public_name = ticket.public_name
    @gender_pronoun = ticket.gender_pronoun
    @iff_days = ticket.iff_days
    @person_id = person.id
    @ticket_id = ticket.id
    @conference = conference
    @link = cfp_person_url(conference_acronym: @conference.acronym)

    mail(
      to: person.email,
      subject: I18n.t('emails.ticketing_mail.subject', conference_alt_title: @conference.alt_title),
      locale: :en
    )
  end
end
