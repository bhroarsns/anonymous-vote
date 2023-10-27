class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_SENDER_NAME']
  layout "mailer"
end
