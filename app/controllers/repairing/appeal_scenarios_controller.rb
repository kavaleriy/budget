module Repairing
  # List appeal scenarios
  class AppealScenariosController < AdminController
    before_action :set_repairing_appeal_scenario, only: [:show, :edit, :update, :destroy]

    respond_to :html

    def index
      @repairing_appeal_scenarios = Repairing::AppealScenario.all
      respond_with(@repairing_appeal_scenarios)
    end

    def show
      respond_with(@repairing_appeal_scenario)
    end

    def new
      @repairing_appeal_scenario = Repairing::AppealScenario.new
      respond_with(@repairing_appeal_scenario)
    end

    def edit; end

    def create
      @repairing_appeal_scenario = Repairing::AppealScenario.new(appeal_scenario_params)
      @repairing_appeal_scenario.save
      respond_with(@repairing_appeal_scenario)
    end

    def update
      @repairing_appeal_scenario.update(appeal_scenario_params)
      respond_with(@repairing_appeal_scenario)
    end

    def destroy
      @repairing_appeal_scenario.destroy
      respond_with(@repairing_appeal_scenario)
    end

    private

    def set_repairing_appeal_scenario
      @repairing_appeal_scenario = Repairing::AppealScenario.find(params[:id])
    end

    def appeal_scenario_params
      params.require(:repairing_appeal_scenario).permit(:title, :text_form, :text_appeal)
    end

  end
end
