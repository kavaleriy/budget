class BudgetFileRov < BudgetFile

  protected

  def get_taxonomy file_name, columns
    TaxonomyRov.get_taxonomy(file_name)
  end

end
