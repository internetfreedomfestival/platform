class TicketingMailer < ApplicationMailer
  def ticketing_mail(ticket, person, conference)
    @first_name = person.first_name
    @public_name = ticket.public_name
    @gender_pronoun = ticket.gender_pronoun
    @iff_days = ticket.iff_days
    @id = person.user_id
    @link = cfp_person_url(conference_acronym: conference.acronym)

    mail(
      to: person.email,
      subject: I18n.t('emails.ticketing_mail.subject'),
      locale: :en
    )
  end
end
