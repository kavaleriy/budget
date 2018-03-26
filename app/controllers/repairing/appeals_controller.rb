module Repairing
  class AppealsController < ApplicationController
    layout 'application_admin'
    before_action :access_user?, only: [:index]
    before_action :set_repairing_appeal, only: [:show]
    before_action :set_repair, only: [:new]
    before_action :set_scenario, only: [:new]


    respond_to :html

    def index
      @repairing_appeals = Repairing::Appeal.all
      respond_with(@repairing_appeals)
    end

    def show
      respond_with(@repairing_appeal)
    end

    def new
      # binding.pry
      @repairing_appeal = Repairing::Appeal.new
      respond_with(@repairing_appeal, layout: 'application')
    end

    def preview
      @repairing_appeal = Repairing::Appeal.new(appeal_params)
      render layout: 'application'
    end

    # def edit; end

    def create
      @repairing_appeal = Repairing::Appeal.new(appeal_params)
      @repairing_appeal.save
      respond_with(@repairing_appeal)
    end

    # def update
    #   @repairing_appeal.update(appeal_params)
    #   respond_with(@repairing_appeal)
    # end
    #
    # def destroy
    #   @repairing_appeal.destroy
    #   respond_with(@repairing_appeal)
    # end

    private

    def access_user?
      unless current_user && current_user.admiin?
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def set_repairing_appeal
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def set_repair
      @repair = Repairing::Repair.find(params[:repair_id])
    end

    def set_scenario
      @scenario = Repairing::AppealScenario.find(params[:scenario_id])
    end

    def appeal_params
      params.require(:repairing_appeal).permit(
        :repair,
        :scenario,
        :full_name,
        :email,
        :phone,
        :text,
        :user_consent,
        :file,
        address: %i[city street house apartment],
        recipients: []
      )
    end
  end
end