class TaxonomyRotsController < TaxonomiesController

  def taxonomy_params
    params.require(:taxonomy_rot).permit(:title)
  end


end
