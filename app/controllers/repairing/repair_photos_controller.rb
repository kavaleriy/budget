module Repairing
  class RepairPhotosController < ApplicationController
    before_action :set_repair

    def create
      # respond_to do |format|
      #   if @repairing_repair.photos.create!(photo_params)
      #     flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')
      #     format.html { redirect_to repairing_repair_photos_path(@repairing_repair) }
      #     format.js { render 'repairing/repairs/photos' }
      #   else
      #
      #     flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')
      #     format.html { redirect_to repairing_repair_photos_path(@repairing_repair) }
      #     format.js { render 'repairing/repairs/photos' }
      #   end
      # end
      begin
        @repairing_repair.photos.create!(photo_params)
        flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')

        binding.pry
      rescue Exception => e
        binding.pry
        # logger.warn("Unable to save record: #{self.to_yaml}. Error: #{e}")
        # errors[:base] << "Please correct the errors in your form"
        # false

        flash.now[:notice] = e
      end

      respond_to do |format|
        # if @repairing_repair.photos.create!(photo_params)
        #   flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')
        # else
        #   flash.now[:notice] = 'Not saved'
        # end

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