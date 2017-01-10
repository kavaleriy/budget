class BudgetFileFreesController < BudgetFilesController
  include BudgetFileTerra
  before_action :set_areas, only: [:new]

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileFree.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileFree.new
    end

    budget_file
  end

  def get_taxonomies
    TaxonomyFree.by_town(current_user.town_model)
  end

  def create_taxonomy area_id, file_name
    TaxonomyFree.find_or_create_by!(id: params[:budget_file_taxonomy])
  end

end
