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

  def accepted_event_email(event)
    email = event.submitter.email

    @conference = event.conference
    @first_name = event.submitter.first_name
    @title = event.title
    @theme = event.event_type
    @time_slots = event.time_slots

    mail(
      to: email,
      subject: "Congrats! You’ll be presenting at the #{@conference.alt_title}",
      locale: :en
    )
  end

  def rejected_event_email(event)
    email = event.submitter.email

    @conference = event.conference
    @first_name = event.submitter.first_name
    @title = event.title

    mail(
      to: email,
      subject: "Your IFF Session Review",
      locale: :en
    )
  end
end
