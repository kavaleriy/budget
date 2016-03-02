class Widgets::TownProfileController < Widgets::WidgetsController

  def portfolio
    @town = Town.find(params[:town_id])
    @town_items = get_town_items_hash(@town)
    respond_to do |format|
      format.js {}
      format.html{render :partial => 'portfolio'}
    end

  end

  private

  def get_town_items_hash (town_object)
    @town = town_object
    town = nil
    town = town_object.title unless town_object.blank?
    # taxonomy_rot = TaxonomyRot.get_rot_by_owner_city(town).last
    # taxonomy_rov = TaxonomyRov.get_rov_by_owner_city(town).last
    taxonomy = Taxonomy.owned_by(town_object.to_s).first
    calendar = Calendar.get_calendar_by_town(town).first
    indicate_taxonomy = Indicate::Taxonomy.get_indicate_by_town(town_object).last

    result = []
    result << get_indicate_hash(indicate_taxonomy,'indicators')
    result << get_taxonomy_rot_hash(taxonomy,'budget')
    result << get_calendar_hash(calendar,'calendar')
    # result << get_taxonomy_rov_hash(taxonomy_rov,'budget')
    result << get_repair_hash('repair')
    result << get_programs_hash('programs')
    result << get_key_docs_hash('key_docs')
    result << get_prozorro_hash('prozoroo')
    result << get_edata_hash('edata')
    result << get_purchase_hash('purchase')
    result << get_keys_hash('keys')

    result.compact
  end

  def get_taxonomy_rot_hash(taxonomy_rot,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#') do
      unless taxonomy_rot.nil?
        return {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> public_budget_files_path(@town)}
      end
    end
  end

  def get_indicate_hash(indicate,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#') do
      unless indicate.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> indicate_taxonomies_town_profile_path(@town)}
      end
    end
  end

  def get_taxonomy_rov_hash(taxonomy_rov,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#') do
      unless taxonomy_rov.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> taxonomies_town_profile_path(@town)}
      end
    end
  end

  def get_calendar_hash(calendar,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#') do
      unless calendar.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> calendars_calendars_town_path(@town)}
      end
    end
  end

  def get_keys_hash(name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#') do
      if @town.key_indicate_map_indicators
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> key_indicate_map_indicators_get_town_profile_path(@town)}
      end
    end
  end

  def get_item_hash(item_img_src,item_title,item_url)
    result = yield if block_given?
    unless result.nil?
      return result
    end
    unless item_url == "#"
      {'title' => item_title, 'img_src' => item_img_src, 'url'=> item_url}
    end

  end


  def get_repair_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), repairing_map_profile_path(@town))
  end

  def get_key_docs_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), public_documents_town_profile_path(@town))
  end

  def get_programs_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), programs_towns_town_profile_path(@town))
  end

  def get_prozorro_hash(name)
    get_item_hash("/assets/public/" + name + ".png", title_for_portfolio(name), 'http://bi.prozorro.org/sense/app/fba3f2f2-cf55-40a0-a79f-b74f5ce947c2/sheet/HbXjQep/state/analysis')
  end
  def get_edata_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), 'http://www.spending.gov.ua/')
  end
  def get_purchase_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), 'https://ips.vdz.ua/ua/purchase_search.htm')
  end

  def img_url (item)
    "/assets/public/" + item + ".jpg"
  end

  def title_for_portfolio (item)
    I18n.t('public.towns.portfolio.' + item)
  end
end