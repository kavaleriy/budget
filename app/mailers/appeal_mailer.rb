class AppealMailer < ApplicationMailer
  helper :application

  def email_to_user(appeal)
    @repairing_appeal = appeal
    email_attachments
    user = @repairing_appeal.email

    mail(to: user, subject: 'Ваше звернення.')
  end

  def email_to_recipients(appeal)
    @repairing_appeal = appeal
    email_attachments
    recipients = @repairing_appeal.recipients.pluck(:email).join(",")

    mail(to: recipients, subject: 'Звернення.')
  end

  def disapprove_email(appeal)
    @repairing_appeal = appeal
    email_attachments
    user = @repairing_appeal.email

    mail(to: user, subject: 'Ваше звернення не пройшло модерацію.')
  end

  def email_attachments
    attachments["Ремонт_#{@repairing_appeal.id}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(
          pdf: 'send_appeal',
          template: 'appeal_mailer/email_to_recipients',
          layout: 'mailer'
        )
      )
  end

end
