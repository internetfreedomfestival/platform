class TicketingMailer < ApplicationMailer
  def ticketing_mail(person, conference)
    @first_name = Person.find_by(email: person.email).first_name
    @public_name = Person.find_by(email: person.email).public_name
    @gender_pronoun = Person.find_by(email: person.email).gender_pronoun
    @iff_days = Person.find_by(email: person.email).iff_days
    @id = Person.find_by(email: person.email).user_id
    @link = cfp_root_url(conference_acronym: conference.acronym)

    mail(
      to: person.email,
      subject: I18n.t('emails.ticketing_mail.subject'),
      locale: :en
    )
  end
end
