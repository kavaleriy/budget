class Modules::SlidersController < AdminController
  before_action :set_modules_slider, only: [:show, :edit, :update, :destroy,:crop_update]

  respond_to :html

  def index
    @modules_sliders = Modules::Slider.all
    respond_with(@modules_sliders)
  end

  def show
    respond_with(@modules_slider)
  end

  def new
    Modules::Slider.all.each { |sl| sl.destroy }
    @modules_slider = Modules::Slider.new
    respond_with(@modules_slider)
  end

  def edit
  end

  def create
    @modules_slider = Modules::Slider.new(modules_slider_params)
    if @modules_slider.save
      render 'crop'
    else
      respond_with(@modules_slider)
    end
  end

  def update
    unless modules_slider_params[:img].blank?
      if Modules::Slider.new(modules_slider_params).valid?
        @modules_slider.delete_image_file!
      end
    end
    @modules_slider.update(modules_slider_params)
    render 'crop'
    # respond_with(@modules_slider)
  end

  def destroy
    @modules_slider.delete_image_file!
    @modules_slider.destroy
    respond_with(@modules_slider)
  end

  def crop_update
    @modules_slider.crop_x = params[:modules_slider]["crop_x"]
    @modules_slider.crop_y = params[:modules_slider]["crop_y"]
    @modules_slider.crop_h = params[:modules_slider]["crop_h"]
    @modules_slider.crop_w = params[:modules_slider]["crop_w"]
    @modules_slider.save
    redirect_to modules_sliders_path
  end

  private
    def set_modules_slider
      @modules_slider = Modules::Slider.find(params[:id])
    end

    def modules_slider_params
      params.require(:modules_slider).permit(:text, :img,:sl_order)
    end
end
