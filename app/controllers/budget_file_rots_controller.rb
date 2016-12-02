class BudgetFileRotsController < BudgetFilesController

  include BudgetFileTerra
  before_action :set_areas, only: [:new]

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileRot.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileRot.new
    end

    budget_file.data_type = :plan

    budget_file
  end

  def get_taxonomies
    TaxonomyRot.by_town(current_user.town_model)
    # TaxonomyRot.owned_by(current_user.town)
  end

  def create_taxonomy area_id, file_name
    name = file_name.gsub(/rot\d{5}\.(?<TERRA>\d\d\d).*/i, 'FTxxxxxx.\k<TERRA>.' + area_id)
    taxonomy = TaxonomyRot.find_or_create_by!(owner: @town_title, name: name)

    get_title = -> () do
      /rot\d{5}\.(?<town_id>\d\d\d).*/i =~ file_name
      get_terra_title area_id, town_id
    end

    taxonomy.title = get_title.call
    taxonomy.area = area_id

    taxonomy
  end

  def get_file_title
    /rot\d{5}\.(?<town_id>\d\d\d).*/i =~ @file_name
    area_id = params[:area]
    "#{@file_name} #{get_terra_title(area_id, town_id)}"
  end

end
