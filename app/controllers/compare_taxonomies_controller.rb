class CompareTaxonomiesController < ApplicationController

  def index
    stub_data
  end

  def get_amounts_list
    # [ t('amount_uah'), t('amount_usd'), t('amount_citizens'), t('amount_house_holdings'), t('amount_square') ]
    [ t('amount_uah'), t('amount_usd'), t('amount_citizens'), t('amount_square') ].map.with_index{ |title, i|
      {id: i, title: title}
    }
  end

  def stub_data
    @towns_with_tax_rov = TaxonomyRov.get_active_for_all_towns
    binding.pry
    @towns_with_tax_rot = TaxonomyRot.get_active_for_all_towns

    @current_year = Date.current.year
    @years = (@current_year - 3) .. @current_year

    @amounts = get_amounts_list
  end

  def compare_budget
    stub_data
    respond_to do |format|
      format.js
    end
  end

end