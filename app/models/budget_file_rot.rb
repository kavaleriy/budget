class BudgetFileRot < BudgetFile

  protected

  def get_taxonomy file_name, columns
    TaxonomyRot.get_taxonomy(file_name)
  end

end
