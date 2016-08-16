class Modules::BannersController < AdminController
  layout 'application_admin'
  before_action :check_admin_permission
  before_action :set_modules_banner, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @modules_banners = Modules::Banner.all.order(order_banner: :desc)
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
    if @modules_banner.save
      flash[:success] = t('modules.banners.action_messages.create.success')
      redirect_to modules_banners_path
    else
      render :new
    end
  end

  def update
    unless params[:modules_banner][:title].blank?
      unless params[:modules_banner][:banner_img].blank?
        @modules_banner.remove_banner_img!
      end
    end
    if @modules_banner.update(modules_banner_params)
      flash[:success] = t('modules.banners.action_messages.update.success')
      redirect_to modules_banners_path
    else
      render :edit
    end
  end

  def destroy
    @modules_banner.destroy
    flash[:success] = t('modules.banners.action_messages.destroy.success')
    respond_with(@modules_banner)
  end

  private
    def set_modules_banner
      @modules_banner = Modules::Banner.find(params[:id])
    end

    def modules_banner_params
      params.require(:modules_banner).permit(:title, :order_banner, :publish_on, :banner_img, :banner_url)
    end
end
