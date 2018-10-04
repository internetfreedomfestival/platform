class EventsMailer < ApplicationMailer
  def create_event_mail(email, event)
    @session_title = event.title
    @link = cfp_person_url(conference_acronym: event.conference.acronym)

    mail(
      to: email,
      subject: I18n.t('emails.event_mail.subject'),
      locale: :en
    )
  end
end
