module Repairing
  class RepairPhotosController < ApplicationController
    before_action :set_repair

    def create
      respond_to do |format|
        if @repairing_repair.photos.create!(photo_params)
          format.html{ redirect_to repairing_repair_photos_path(@repairing_repair), notice: t('repairing.repairs.repair_info.photo_saved')}
          format.json { render :show, status: :ok, location: @repairing_repair }
        else
          @photo = @repairing_repair.photos.find(params[:id])
          format.html { render 'repairing/repairs/photos', notice: t('errors.messages.not_saved')}
          format.json { render json: @photo.errors, status: :unprocessable_entity, location: [@repairing_repair, @photo] }
        end
      end
    end

    def destroy
      @repairing_repair.photos.find(params[:photo_id]).destroy
      redirect_to repairing_repair_photos_path(@repairing_repair), notice: t('repairing.repairs.repair_info.photo_deleted')
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