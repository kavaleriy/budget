class TaxonomyRovsController < TaxonomiesController

  def taxonomy_params
    params.require(:taxonomy_rov).permit(:title)
  end

end
