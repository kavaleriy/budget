class BudgetFileRovsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRov.new
    @budget_file.data_type = :plan
  end

  def get_taxonomies
    TaxonomyRot.by_town(current_user.town_model)
  end

  def create_taxonomy
    TaxonomyRov.create!(:owner => @town_title)
  end

end
