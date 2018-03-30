class AppealMailer < ApplicationMailer
  helper :application

  def send_appeal(appeal)
    @repairing_appeal = appeal
    recipients = @repairing_appeal.recipients.join(",")

    attachments["Ремонт_#{@repairing_appeal.id}.pdf"] =
      WickedPdf.new.pdf_from_string(
  render_to_string(
          pdf: 'send_appeal',
          template: 'appeal_mailer/send_appeal',
          layout: 'mailer'
        )
      )

    mail(to: recipients, subject: 'Звернення.')
  end
end
