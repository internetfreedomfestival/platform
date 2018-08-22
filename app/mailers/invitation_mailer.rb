class InvitationMailer < ApplicationMailer
  def invitation_mail(invited)
    @person = invited.person
    @conference = invited.conference
    @link = ticketing_form_url(id: invited.id, conference_acronym: @conference.acronym)
    mail(
      to: @person.email,
      subject: I18n.t('emails.invitation_mail.subject'),
      locale: :en
    )
  end
  def additional_invitation_mail(invited)
    @person = invited.person
    @conference = invited.conference
    @link = ticketing_form_url(id: invited.id, conference_acronym: @conference.acronym)
    mail(
      to: "invited@email.com",
      subject: I18n.t('emails.additional_invitation_mail.subject'),
      locale: :en
    )
  end
end
