class UserMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def password_reset_instructions(user, conference)
    @user = user
    @conference = conference
    mail to: @user.email, subject: I18n.t('mailers.user_mailer.password_reset_instructions')
  end

  def confirmation_instructions(user, conference = nil)
    @user = user
    @conference = conference
    # I18n.t('Account Activation')
    mail to: @user.email, subject: I18n.t('mailers.user_mailer.confirmation_instructions')
  end

  def bulk_mail(user, template)
    mail to: user.email, subject: template.subject, body: template.content_for(user)
  end

  def send_event_accepted_conf(user, event, conference)
    @user = user
    @event = event
    @conference = conference
    @person = Person.find_by(user_id: user.id)
    mail to: @user.email, subject: "Your #{@conference.alt_title} Event has been accepted!"
  end
end
