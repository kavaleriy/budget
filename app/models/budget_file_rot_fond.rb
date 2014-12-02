class BudgetFileRotFond < BudgetFileRot

  protected

  def get_taxonomy owner, columns
    TaxonomyRotFond.get_taxonomy(owner)
  end

end
