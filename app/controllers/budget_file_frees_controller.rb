class BudgetFileFreesController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileFree.new
  end

  def get_taxonomies owner
    TaxonomyFree.where(:owner => owner)
  end

  def create_taxonomy owner
    TaxonomyFree.create!(:owner => owner)
  end

  def find_taxonomy owner
    TaxonomyFree.where(:owner => owner).first
  end

end
