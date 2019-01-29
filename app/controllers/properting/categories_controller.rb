class Properting::CategoriesController < AdminController
  layout 'application_admin'

  before_action :set_properting_category, only: %i[show edit update destroy]

  def index
    @properting_categories = Properting::Category.all
  end

  def show
    @properting_categories = properting_categories(@properting_category.id)
    respond_to do |format|
      format.js
    end
  end

  def tree_root
    @properting_categories = Properting::Category.tree_root
  end

  def tree
    @properting_categories = Properting::Category.tree(params[:id])
  end

  def new
    @properting_category = Properting::Category.new
  end

  def edit; end

  def create
    @properting_category = Properting::Category.new(properting_category_params)
    @properting_category.parent = Properting::Category.find(properting_category_params.category_id) if properting_category_params.respond_to? :category_id

    respond_to do |format|
      if @properting_category.save
        format.json { render :show, status: :created, location: @properting_category }
      else
        format.json { render json: @properting_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    unless properting_category_params[:position].nil? && properting_category_params[:category_id].nil?
      new_position = properting_category_params[:position].to_i
      new_category_id = properting_category_params[:category_id]
      old_category_id = @properting_category.category_id.to_s
      recalc_positions(new_category_id, params[:id], new_position)
    end

    respond_to do |format|
      if @properting_category.update(properting_category_params)
        recalc_positions(old_category_id, nil) unless old_category_id.nil? && new_category_id.nil? && old_category_id == new_category_id
        @flash = { 'message' => 'Дані успішно збережені', 'class' => 'alert-success' }
        format.js
        format.json { render :show, status: :ok, location: @properting_category }
      else
        @flash = { 'message' => 'Помилка збереження даних.', 'class' => 'alert-danger' }
        format.js
        format.json { render json: @properting_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    properting_categories(@properting_category.id).each(&:destroy)
    @properting_category.destroy
    respond_to do |format|
      format.html { redirect_to properting_categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def recalc_positions(category_id, id, new_position=-1)
    position = 0
    properting_categories(category_id).each { |category|
      next if category.id.to_s == id

      position = new_position + 1 if position == new_position
      category.update(position: position)
      puts "#{category.position} - #{category.title}"
      position += 1
    }
  end

  def set_properting_category
    @properting_category = Properting::Category.find(params[:id])
  end

  def properting_categories(category_id)
    Properting::Category.where(category_id: category_id)
  end

  def properting_category_params
    params.require(:properting_category).permit(:category_id, :title, :icon, :color, :position, :img, :locale)
  end
end
