class BudgetFileRotsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRot.new
  end

  def get_taxonomies owner
    TaxonomyRot.where(:owner => owner)
  end

  def create_taxonomy owner
    TaxonomyRot.create!(:owner => owner)
  end

  def find_taxonomy owner
    TaxonomyRot.where(:owner => owner).first
  end

end
