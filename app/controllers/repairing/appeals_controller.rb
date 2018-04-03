module Repairing
  class AppealsController < ApplicationController
    layout 'application_admin'
    before_action :access_user?, only: [:index]
    before_action :set_repairing_appeal, only: [:show, :edit, :update, :approve, :disapprove_form, :disapprove]
    before_action :set_repair, only: [:new, :create, :edit]
    before_action :set_scenario, only: [:new, :create, :edit]

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
      respond_with(@repairing_appeal, layout: 'application')
    end

    def preview
      @repairing_appeal = Repairing::Appeal.new(appeal_params)
      render layout: 'application'
    end

    # def edit; end

    def create
      @repairing_appeal = Repairing::Appeal.new(appeal_params)

      respond_to do |format|
        if @repairing_appeal.save
          format.html { redirect_to repairing_appeal_saved_path }
        else
          format.html { render :new, layout: 'application' }
          format.json { render json: @repairing_appeal.errors, status: :unprocessable_entity }
        end
      end
    end

    def appeal_saved
      render layout: 'application'
    end

    def approve
      respond_to do |format|
        if @repairing_appeal.update(approved: true)
          AppealMailer.email_to_user(@repairing_appeal).deliver
          AppealMailer.email_to_recipients(@repairing_appeal).deliver
          msg = { class_name: 'success', message: 'Звернення одобрено.' }
        else
          msg = { class_name: 'danger', message: I18n.t('repairing.layers.update.error') }
        end

        format.js { flash.now[msg[:class_name]] = msg[:message] }
      end
    end

    def disapprove_form
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def disapprove
      respond_to do |format|
        if @repairing_appeal.update(not_approved_text: params[:not_approved_text])
          AppealMailer.disapprove_email(@repairing_appeal).deliver
          msg = { class_name: 'success', message: 'Повідомлення про відмову відправено.' }
        else
          msg = { class_name: 'danger', message: I18n.t('repairing.layers.update.error') }
        end
        format.js { flash.now[msg[:class_name]] = msg[:message] }
      end
    end

    def update
      @repairing_appeal.update(appeal_params)
      respond_with(@repairing_appeal)
    end

    # def destroy
    #   @repairing_appeal.destroy
    #   respond_with(@repairing_appeal)
    # end

    private

    def access_user?
      unless current_user && current_user.admin?
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def set_repairing_appeal
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def set_repair
      @repair = Repairing::Repair.find(params[:repair_id] || appeal_params[:repair] || @repairing_appeal.repair_id )
    end

    def set_scenario
      @scenario = Repairing::AppealScenario.find(params[:scenario_id] || appeal_params[:scenario] || @repairing_appeal.scenario_id)
    end

    # def appeal_approved
    #   params.permit(:approved)
    # end

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