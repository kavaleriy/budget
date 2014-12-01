class BudgetFileRovFond < BudgetFileRov

  protected

  def get_taxonomy file_name, columns
    TaxonomyRovFond.get_taxonomy(file_name)
  end

end
