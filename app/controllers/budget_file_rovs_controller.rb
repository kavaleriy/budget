class BudgetFileRovsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRov.new
  end

  def get_taxonomies owner
    TaxonomyRov.where(:owner => owner)
  end

  def create_taxonomy owner
    TaxonomyRov.create!(:owner => owner)
  end

end
