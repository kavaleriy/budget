class AppealMailer < ApplicationMailer
  helper :application

  def send_appeal(appeal)
    @repairing_appeal = appeal

    recipients = @repairing_appeal.recipients.join(",")
    mail(to: recipients, subject: 'Звернення.')
  end
end
