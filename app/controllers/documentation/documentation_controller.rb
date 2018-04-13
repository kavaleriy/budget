module Documentation
  class DocumentationController < ApplicationController
    before_action :access_user
    layout 'application_admin'

    private

    def access_user
      return if current_user && current_user.has_any_role?(:admin, :city_authority)
      redirect_to :back, alert: t('export_budgets.notice_access')
    end
  end
end