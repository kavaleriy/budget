class Modules::BannersController < AdminController
  layout 'application_admin'
  before_action :check_admin_permission
  before_action :set_modules_banner, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @modules_banners = Modules::Banner.all
    respond_with(@modules_banners)
  end

  def show
    respond_with(@modules_banner)
  end

  def new
    @modules_banner = Modules::Banner.new
    respond_with(@modules_banner)
  end

  def edit
  end

  def create
    @modules_banner = Modules::Banner.new(modules_banner_params)
    @modules_banner.save
    respond_with(@modules_banner)
  end

  def update
    @modules_banner.update(modules_banner_params)
    respond_with(@modules_banner)
  end

  def destroy
    @modules_banner.destroy
    respond_with(@modules_banner)
  end

  private
    def set_modules_banner
      @modules_banner = Modules::Banner.find(params[:id])
    end

    def modules_banner_params
      params.require(:modules_banner).permit(:title, :order_banner, :publish_on)
    end
end
