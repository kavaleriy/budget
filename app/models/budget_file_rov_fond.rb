class BudgetFileRovFond < BudgetFileRov

  protected

  def get_taxonomy owner, columns
    TaxonomyRovFond.get_taxonomy(owner)
  end

end
