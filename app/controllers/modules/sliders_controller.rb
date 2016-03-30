class Modules::SlidersController < AdminController
  before_action :set_modules_slider, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @modules_sliders = Modules::Slider.all
    respond_with(@modules_sliders)
  end

  def show
    respond_with(@modules_slider)
  end

  def new
    @modules_slider = Modules::Slider.new
    respond_with(@modules_slider)
  end

  def edit
  end

  def create
    @modules_slider = Modules::Slider.new(modules_slider_params)
    @modules_slider.save
    respond_with(@modules_slider)
  end

  def update
    unless modules_slider_params[:img].blank?
      if Modules::Slider.new(modules_slider_params).valid?
        @modules_slider.delete_image_file!
      end
    end
    @modules_slider.update(modules_slider_params)
    respond_with(@modules_slider)
  end

  def destroy
    @modules_slider.destroy
    respond_with(@modules_slider)
  end

  private
    def set_modules_slider
      @modules_slider = Modules::Slider.find(params[:id])
    end

    def modules_slider_params
      params.require(:modules_slider).permit(:text, :img,:sl_order)
    end
end
