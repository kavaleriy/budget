module Repairing::LayersHelper
  def get_status(status)
    status.eql?('fact') ? t('js.visify.fact') : t('js.visify.plan')
  end
end
