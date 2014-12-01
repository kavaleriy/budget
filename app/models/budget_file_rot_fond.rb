class BudgetFileRotFond < BudgetFileRot

  protected

  def get_taxonomy file_name, columns
    TaxonomyRotFond.get_taxonomy(file_name)
  end

end
