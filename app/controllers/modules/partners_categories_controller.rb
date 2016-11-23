class Modules::PartnersCategoriesController < AdminController
  before_action :set_modules_partners_category, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @modules_partners_categories = Modules::PartnersCategory.all
    respond_with(@modules_partners_categories)
  end

  def show
    respond_with(@modules_partners_category)
  end

  def new
    @modules_partners_category = Modules::PartnersCategory.new
    respond_with(@modules_partners_category)
  end

  def edit
  end

  def create
    @modules_partners_category = Modules::PartnersCategory.new(modules_partners_category_params)
    @modules_partners_category.save
    respond_with(@modules_partners_category)
  end

  def update
    @modules_partners_category.update(modules_partners_category_params)
    respond_with(@modules_partners_category)
  end

  def destroy
    @modules_partners_category.destroy
    respond_with(@modules_partners_category)
  end

  private
    def set_modules_partners_category
      @modules_partners_category = Modules::PartnersCategory.find(params[:id])
    end

    def modules_partners_category_params
      params.require(:modules_partners_category).permit(:title, :alias_str)
    end
end
