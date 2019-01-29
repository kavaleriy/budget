module Properting
  class PropertyPhotosController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create
    before_action :set_property

    def create
      @properting_property.photos.create!(photo_params)
      flash.now[:notice] = t('repairing.repairs.repair_info.photo_saved')

      respond_to do |format|
        format.html { redirect_to properting_property_photos_path(@properting_property) }
        format.js { render 'properting/properties/photos' }
      end
    end

    def destroy
      @properting_property.photos.find(params[:photo_id]).destroy

      respond_to do |format|
        flash.now[:notice] = t('repairing.repairs.repair_info.photo_deleted')
        format.html { redirect_to properting_property_photos_path(@properting_property) }
        format.js { render 'properting/properties/photos' }
      end
    end

    private

    def set_property
      @properting_property = Properting::Property.find(params[:id])
    end

    def photo_params
      params.require(:properting_photo).permit(:image)
    end
  end
end
