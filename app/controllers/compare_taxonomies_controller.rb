class CompareTaxonomiesController < ApplicationController

  def index
    @taxonomies = TaxonomyRov.all

    @current_year = Date.current.year
    @years = (@current_year - 3) .. @current_year
  end

end