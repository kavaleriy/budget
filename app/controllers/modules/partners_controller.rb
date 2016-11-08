class Modules::PartnersController < AdminController
  layout 'application_admin'
  before_action :set_modules_partner, only: [:show, :edit, :update, :destroy]
  before_action :get_modules_partners, only: [:index, :new, :change_order]

  respond_to :html

  def index
    respond_with(@modules_partners)
  end

  def show
    respond_with(@modules_partner)
  end

  def new
    @modules_partner = Modules::Partner.new
    respond_with(@modules_partner)
  end

  def edit
  end

  def create
    @modules_partner = Modules::Partner.new(modules_partner_params)
    if @modules_partner.save
      flash[:success] = t('modules.partners.action_messages.create.success')
      redirect_to modules_partners_path
    else
      render :new
    end
  end

  def update
    unless params[:modules_partner][:name].blank?
      unless params[:modules_partner][:logo].blank?
        @modules_partner.remove_logo!
      end
    end
    if @modules_partner.update(modules_partner_params)
      flash[:success] = t('modules.partners.action_messages.update.success')
      redirect_to modules_partners_path
    else
      render :edit
    end
  end

  def change_order
    partner_up = Modules::Partner.find(params[:partner_up])
    partner_down = Modules::Partner.find(params[:partner_down])
    partner_up_order = partner_up.order_logo
    partner_down_order = partner_down.order_logo
    partner_up.update_attribute(:order_logo, partner_down_order)
    partner_down.update_attribute(:order_logo, partner_up_order)

    respond_to do |format|
      format.js
      format.html{redirect_to modules_partners_path}
    end
  end

  def destroy
    if @modules_partner.destroy
      reorder_partners(@modules_partner.order_logo)
    end
    flash[:success] = t('modules.partners.action_messages.destroy.success')
    respond_with(@modules_partner)
  end

  private
    def reorder_partners(order_partner)
      modules_partners = Modules::Partner.where(:order_logo.gt => order_partner).order(order_logo: :asc)
      i = order_partner
      modules_partners.each do |partner|
        partner.update_attribute(:order_logo, i)
        i+=1
      end
    end

    def get_modules_partners
      @modules_partners = Modules::Partner.order(order_logo: :asc)
    end

    def set_modules_partner
      @modules_partner = Modules::Partner.find(params[:id])
    end

    def modules_partner_params
      params.require(:modules_partner).permit(:name, :url, :publish_on, :category, :logo)
    end
end
