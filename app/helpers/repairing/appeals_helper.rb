module Repairing::AppealsHelper
  def appeal_disable(appeal)
    # check if appeal approved or disapprove_form
    appeal.approved.present? || appeal.not_approved_text.present? ? 'btn disabled' : 'btn'
  end

  def appeal_status(appeal)
    if appeal.not_approved_text.present?
      'Відмовлено'
    elsif appeal.approved.present?
      'Одобрено'
    else
      'Очікує модерації'
    end
  end
end
