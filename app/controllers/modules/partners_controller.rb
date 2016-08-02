class Modules::PartnersController < ApplicationController
  layout 'application_admin'
  before_action :set_modules_partner, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @modules_partners = Modules::Partner.all
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
    @modules_partner.save
    respond_with(@modules_partner)
  end

  def update
    @modules_partner.update(partner_params)
    respond_with(@modules_partner)
  end

  def destroy
    @modules_partner.destroy
    respond_with(@modules_partner)
  end

  private
    def set_modules_partner
      @modules_partner = Modules::Partner.find(params[:id])
    end

    def modules_partner_params
      params.require(:modules_partner).permit(:name, :order_logo, :publish_on, :logo)
    end
end
