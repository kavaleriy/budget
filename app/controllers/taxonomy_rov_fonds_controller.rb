class TaxonomyRovFondsController < TaxonomiesController

  def taxonomy_params
    params.require(:taxonomy_rov_fond).permit(:title)
  end

end
