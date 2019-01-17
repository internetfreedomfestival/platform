class PeopleMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')

  def bulk_mail(person, template)
    mail to: person.email, subject: template.subject, body: template.content_for(person, template.conference)
  end
end
