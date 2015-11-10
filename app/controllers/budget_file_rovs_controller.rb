class BudgetFileRovsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRov.new
  end

  def get_taxonomies owner
    TaxonomyRov.owned_by(current_user.town)
  end

  def create_taxonomy
    TaxonomyRov.create!(:owner => @owner)
  end

end
