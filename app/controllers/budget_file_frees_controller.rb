class BudgetFileFreesController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileFree.new
  end

  def get_taxonomies owner
    TaxonomyFree.where(:owner => owner)
  end

  def create_taxonomy
    TaxonomyFree.create!(:owner => @town_title)
  end

end
