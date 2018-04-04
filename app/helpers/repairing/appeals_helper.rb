module Repairing::AppealsHelper
  def appeal_status_class(appeal)
    btns = {
      pending: 'btn-info',
      approved: 'btn-success',
      declined: 'btn-danger'
    }

    "#{btns[appeal.status]} btn disabled"
  end

  def appeal_status(appeal)
    titles = {
      pending: 'Очікує модерації',
      approved: 'Одобрено',
      declined: 'Відмовлено'
    }

    titles[appeal.status]
  end
end
