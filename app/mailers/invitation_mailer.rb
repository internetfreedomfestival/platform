class InvitationMailer < ApplicationMailer
  def invitation_mail(person, conference)
    @person = person
    @conference = conference
    @link = ticketing_form_person_url(id: @person.id, conference_acronym: @conference.acronym)
    mail(
      to: person.email,
      subject: I18n.t('emails.invitation_mail.subject'),
      locale: :en
    )
  end
end
