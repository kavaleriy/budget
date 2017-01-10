class BudgetFileRovsController < BudgetFilesController
  include BudgetFileTerra
  before_action :set_areas, only: [:new]

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileRov.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileRov.new
    end

    budget_file.data_type = :plan

    budget_file
  end

  def get_taxonomies
    TaxonomyRot.by_town(current_user.town_model)
  end

  def create_taxonomy area_id, file_name
    name = file_name.gsub(/rov\d{5}\.(?<TERRA>\d\d\d).*/i, 'VDxxxxxx.\k<TERRA>.' + area_id)
    taxonomy = TaxonomyRov.find_or_create_by!(name: name)

    taxonomy.title = get_file_title
    taxonomy.area = area_id

    taxonomy
  end

  def get_file_title
    /rov\d{5}\.(?<town_id>\d\d\d).*/i =~ @file_name
    area_id = params[:area]
    "#{get_terra_title(area_id, town_id)}"
  end

end
