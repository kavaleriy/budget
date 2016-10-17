class BudgetFileRotsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRot.new
    @budget_file.data_type = :plan
  end

  def get_taxonomies owner
    TaxonomyRot.owned_by(current_user.town)
  end

  def create_taxonomy
    TaxonomyRot.create!(:owner => @town_title)
  end

end
