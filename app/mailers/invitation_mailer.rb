class InvitationMailer < ApplicationMailer
  def invitation_mail(invite)
    @first_name = Person.find_by('lower(email) = ?', invite.email).first_name
    @conference = invite.conference
    @link = ticketing_form_url(id: invite.id, conference_acronym: @conference.acronym)

    mail(
      to: invite.email,
      subject: I18n.t('emails.invitation_mail.subject'),
      locale: :en
    )
  end

  def not_registered_invitation_mail(invite)
    @conference = invite.conference

    @link = ticketing_form_url(id: invite.id, conference_acronym: @conference.acronym)

    mail(
      to: invite.email,
      subject: I18n.t('emails.not_registered_invitation_mail.subject'),
      locale: :en
    )
  end

  def additional_invitation_mail(invite)
    person = invite.person
    @conference = invite.conference

    @first_name = person.first_name
    @link = ticketing_form_url(id: invite.id, conference_acronym: @conference.acronym)

    mail(
      to: invite.email,
      subject: I18n.t('emails.additional_invitation_mail.subject', first_name: @first_name),
      locale: :en
    )
  end

  def request_invitation_mail(person, conference)
    @first_name = person.first_name
    @conference = conference

    mail(
      to: person.email,
      subject: I18n.t('emails.request_invitation_mail.subject', conference_title: @conference.title),
      locale: :en
    )
  end

  def accept_request_mail(invite)
    @conference = invite.conference

    @first_name = Person.find_by(email: invite.email).first_name
    @link = ticketing_form_url(id: invite.id, conference_acronym: @conference.acronym)

    mail(
      to: invite.email,
      subject: I18n.t('emails.accept_request_mail.subject', conference_alt_title: @conference.alt_title),
      locale: :en
    )
  end

  def on_hold_request_mail(person, conference)
    @first_name = Person.find_by(email: person.email).first_name
    @conference = conference

    mail(
      to: person.email,
      subject: I18n.t('emails.on_hold_request_mail.subject'),
      locale: :en
    )
  end
end
