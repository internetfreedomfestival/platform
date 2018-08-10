class InvitationMailer < ApplicationMailer
  def invitation_mail(person, conference)
    @person = person
    @conference = conference

    mail(
      to: person.email,
      subject: I18n.t('emails.invitation_mail.subject'),
      locale: :en
    )
  end
end
