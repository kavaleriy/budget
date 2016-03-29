class Modules::SlidersController < ApplicationController
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
    @modules_slider = Modules::Slider.new(slider_params)
    @modules_slider.save
    respond_with(@modules_slider)
  end

  def update
    @modules_slider.update(slider_params)
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
      params.require(:modules_slider).permit(:text, :img)
    end
end
