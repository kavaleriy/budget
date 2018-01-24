module Municipal
  # common logic of municipal enterprises
  class MunicipalController < ApplicationController
    layout 'application_admin'
    before_action :access_user?

    private

    def access_user?
      unless current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority)
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end
  end
end
