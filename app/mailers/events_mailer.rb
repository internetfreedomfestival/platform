class EventsMailer < ApplicationMailer
  def create_event_mail(email, event)
    @session_title = event.title
    @conference = event.conference
    @link = cfp_person_url(conference_acronym: @conference.acronym)

    mail(
      to: email,
      subject: I18n.t('emails.event_mail.subject', conference_alt_title: @conference.alt_title),
      locale: :en
    )
  end
end
