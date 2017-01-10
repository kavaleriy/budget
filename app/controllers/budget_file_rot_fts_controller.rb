class BudgetFileRotFtsController < BudgetFileRotsController

  include BudgetFileTerra

  before_action :set_areas, only: [:new]

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileRotFt.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileRotFt.new
    end

    budget_file.data_type = :fact
    budget_file.cumulative_sum = true

    budget_file
  end

  def create_taxonomy area_id, file_name
    name = file_name.gsub(/ft(?<BUDGET>\d\d)\d\w\w\d\.(?<TERRA>\d\d\d).*/i, 'FTxxxxxx.\k<TERRA>.' + area_id)
    taxonomy = TaxonomyRot.find_or_create_by!(name: name)

    taxonomy.title = get_title
    taxonomy.area = params[:area]

    taxonomy
  end

  def get_file_name_for uploaded_io
    "#{uploaded_io.original_filename}.dbf"
  end

  def get_title
    /ft(?<code>\d\d)\d\w\w\d\.(?<town_id>\d\d\d).*/i =~ @file_name
    area_id = params[:area]
    "#{get_terra_title(area_id, town_id)}"
  end


end
