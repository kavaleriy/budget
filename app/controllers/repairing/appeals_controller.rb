module Repairing
  class AppealsController < ApplicationController
    layout 'application_admin'
    before_action :access_user, only: [:index, :show, :edit, :update, :destroy, :approve, :disapprove_form, :disapprove]
    before_action :set_repairing_appeal, only: [:show, :edit, :update, :destroy, :approve, :disapprove_form, :disapprove]
    before_action :set_repair, only: [:new, :create, :edit]
    before_action :set_scenario, only: [:new, :create, :edit]

    respond_to :html

    def index
      @repairing_appeals = Repairing::Appeal.by_create.page(params[:page]).per(20)

      respond_to do |format|
        format.js
        format.html
      end
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

    def edit; end

    def create
      @repairing_appeal = Repairing::Appeal.new(appeal_params)
      @repairing_appeal.set_account_number

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
        if @repairing_appeal.update(status: :approved)
          AppealMailer.email_to_user(@repairing_appeal).deliver
          AppealMailer.email_to_recipients(@repairing_appeal).deliver
          msg = { class_name: 'success', message: 'Звернення одобрено.' }
        else
          msg = { class_name: 'danger', message: @repairing_appeal.errors.full_messages }
        end

        format.js { flash.now[msg[:class_name]] = msg[:message] }
      end
    end

    def disapprove_form
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def disapprove
      respond_to do |format|
        if @repairing_appeal.update(status: :declined, declined_text: params[:declined_text])
          AppealMailer.disapprove_email(@repairing_appeal).deliver
          msg = { class_name: 'success', message: 'Повідомлення про відмову відправено.' }
        else
          msg = { class_name: 'danger', message: @repairing_appeal.errors.full_messages }
          set_repairing_appeal
        end

        format.js { flash.now[msg[:class_name]] = msg[:message] }
      end
    end

    def update
      @repairing_appeal.update(appeal_params)
      respond_with(@repairing_appeal)
    end

    def destroy
      @repairing_appeal.destroy
      flash[:success] = t('success_destroy')
      respond_with(@repairing_appeal)
    end

    private

    def access_user
      return if current_user && current_user.admin?
      redirect_to root_url, alert: t('export_budgets.notice_access')
    end

    def set_repairing_appeal
      @repairing_appeal = Repairing::Appeal.find(params[:id])
    end

    def set_repair
      @repair = Repairing::Repair.find(params[:repair_id] || @repairing_appeal.try(:repair_id) || appeal_params[:repair])
    end

    def set_scenario
      @scenario = Repairing::AppealScenario.find(params[:scenario_id] || @repairing_appeal.try(:scenario_id) || appeal_params[:scenario])
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
        recipient_ids: []
      )
    end
  end
end