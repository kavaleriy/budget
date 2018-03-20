module Repairing
  class AppealsController < AdminController
    before_action :set_repairing_appeal, only: [:show, :edit, :update, :destroy]

    respond_to :html

    def index
      @repairing_appeals = Repairing::Appeal.all
      respond_with(@repairing_appeals)
    end

    def show
      respond_with(@repairing_appeal)
    end

    def new
      @repairing_appeal = Repairing::Appeal.new
      respond_with(@repairing_appeal)
    end

    def edit; end

    def create
      @repairing_appeal = Repairing::Appeal.new(appeal_params)
      @repairing_appeal.save
      respond_with(@repairing_appeal)
    end

    def update
      @repairing_appeal.update(appeal_params)
      respond_with(@repairing_appeal)
    end

    def destroy
      @repairing_appeal.destroy
      respond_with(@repairing_appeal)
    end

    private

    def set_repairing_appeal
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def appeal_params
      params.require(:repairing_appeal).permit(
        :full_name,
        :email,
        :phone,
        :text,
        :user_consent,
        address: %i[street house apartment]
      )
    end
  end
end