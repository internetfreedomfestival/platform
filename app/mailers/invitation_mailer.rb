class InvitationMailer < ApplicationMailer
  def invitation_mail(invited)
    @first_name = Person.find_by(email: invited.email).first_name
    @conference = invited.conference
    @link = ticketing_form_url(id: invited.id, conference_acronym: @conference.acronym)

    mail(
      to: invited.email,
      subject: I18n.t('emails.invitation_mail.subject'),
      locale: :en
    )
  end

  def not_registered_invitation_mail(invited)
    conference = invited.conference

    @link = ticketing_form_url(id: invited.id, conference_acronym: conference.acronym)

    mail(
      to: invited.email,
      subject: I18n.t('emails.not_registered_invitation_mail.subject'),
      locale: :en
    )
  end

  def additional_invitation_mail(invited)
    person = invited.person
    conference = invited.conference

    @first_name = person.first_name
    @link = ticketing_form_url(id: invited.id, conference_acronym: conference.acronym)

    mail(
      to: invited.email,
      subject: I18n.t('emails.additional_invitation_mail.subject', first_name: @first_name),
      locale: :en
    )
  end

  def request_invitation_mail(person)
    @first_name = Person.find_by(email: person.email).first_name

    mail(
      to: person.email,
      subject: I18n.t('emails.request_invitation_mail.subject'),
      locale: :en
    )
  end

  def accept_request_mail(invited)
    conference = invited.conference

    @first_name = Person.find_by(email: invited.email).first_name
    @link = ticketing_form_url(id: invited.id, conference_acronym: conference.acronym)

    mail(
      to: invited.email,
      subject: I18n.t('emails.accept_request_mail.subject'),
      locale: :en
    )
  end
end
