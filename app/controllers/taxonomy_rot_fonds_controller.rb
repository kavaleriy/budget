class TaxonomyRotFondsController < TaxonomiesController

  def taxonomy_params
    params.require(:taxonomy_rot_fond).permit(:title)
  end

end
