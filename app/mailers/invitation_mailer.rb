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
end
