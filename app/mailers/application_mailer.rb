class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL')
  layout 'mailer'
end
