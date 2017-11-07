module Repairing
  class RepairPhotosController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: :create
    before_action :set_repair

    def create
      @repairing_repair.photos.create!(photo_params)
      flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')

      respond_to do |format|
        format.html { redirect_to repairing_repair_photos_path(@repairing_repair) }
        format.js { render 'repairing/repairs/photos' }
      end
    end

    def destroy
      @repairing_repair.photos.find(params[:photo_id]).destroy

      respond_to do |format|
        flash.now[:notice] = t('repairing.repairs.repair_info.photo_deleted')
        format.html { redirect_to repairing_repair_photos_path(@repairing_repair) }
        format.js { render 'repairing/repairs/photos' }
      end
    end

    private

    def set_repair
      @repairing_repair = Repairing::Repair.find(params[:id])
    end

    def photo_params
      params.require(:repairing_photo).permit(:image)
    end
  end
end