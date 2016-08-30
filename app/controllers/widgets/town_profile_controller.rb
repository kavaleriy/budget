class Widgets::TownProfileController < Widgets::WidgetsController

  before_action :set_town,:except => [:budget_files_by_taxonomies, :sankey_by_taxonomies,:show_indicates]

  def budget_files
    # this action return hash for navigation panel
    # first element of hash is: first budget profit url(by @town) and budget profit title
    # second element of hash is: first budget outlay url(by @town) and budget outlay title
    # third element of hash is: interrelation url from budget profit and budget outlay and interrelation title
    # set first element of hash is active
    @tabs = []

    taxonomy_rot = TaxonomyRot.owned_by(@town.to_s).first
    taxonomy_rov = TaxonomyRov.owned_by(@town.to_s).first
    sankey_url = widgets_sankey_by_taxonomies_path(taxonomy_rot.id,taxonomy_rov.id) unless taxonomy_rov.nil? || taxonomy_rot.nil?

    @tabs << { title: t('public.towns.budget.tab_rot'), url: "/widgets/visify/bubbletree/#{taxonomy_rot.id}"} if taxonomy_rot
    @tabs << { title: t('public.towns.budget.tab_rov'), url: "/widgets/visify/bubbletree/#{taxonomy_rov.id}"} if taxonomy_rov
    @tabs << { title: t('public.towns.budget.tab_sankey'), url: sankey_url } if sankey_url

    @tabs.first[:cname] = 'active'
  end


  def budget_files_by_taxonomies
    taxonomy_rot = TaxonomyRot.find(params[:tax_rot])
    taxonomy_rov = TaxonomyRov.find(params[:tax_rov])
    sankey = Sankey.by_taxonomies(taxonomy_rot.id,taxonomy_rov.id).first
    @tabs = fill_budget_files_tabs(taxonomy_rot,taxonomy_rov,sankey)

    render 'budget_files'

  end

  def show_indicates
    # this function have url '/widgets/town_profile/show_indicates/:indicate_id'
    # get one params indicate_id(Indicate::Taxonomy.id)
    # find Indicate::Taxonomy by params[:id]
    # get indicators by Indicate::Taxonomy object
    # get years list by Indicate::Taxonomy object
    # set @current_user as current_user(crutch)
    # render indicates/taxonomies/show without layout
    @indicate_taxonomy = Indicate::Taxonomy.find(params[:indicate_id])
    @indicators = @indicate_taxonomy.get_indicators
    @years = @indicators.keys.sort!.reverse!
    @current_user = current_user
  end

  def sankey_by_taxonomies
    # this function have url 'widgets/town_profile/sankey_by_taxonomies/:tax_rot/:tax_rov'

    # get two parameters(TaxonomyRot.id and TaxonomyRov.id)
    # create sankey by Taxonomies
    # check if we can switch to plan , fact
    # render partial 'sankey' with 'sankey' data
    @sankey = Sankey.new('rot_file_id' => params[:tax_rot],'rov_file_id' => params[:tax_rov])
    @sankey.owner = Taxonomy.find(params[:tax_rot]).owner
    @switch_plan_fact = Taxonomy.check_switch_plan_fact(params[:tax_rot],params[:tax_rov])
    render partial: 'sankey', :locals => { sankey: @sankey }
  end

  def portfolio
    # @town = Town.find(params[:town_id])
    @town_items = get_town_items_hash(@town)
    respond_to do |format|
      format.js {}
      format.html{render :partial => 'portfolio'}
    end
  end

  # def budget_compare
  # end

  private

  def fill_budget_files_tabs(tax_rot,tax_rov,sankey)
    tabs = []
    tabs << { title: t('public.towns.budget.tab_rot'), url: widgets_bubbletree_path(tax_rot)} if tax_rot
    tabs << { title: t('public.towns.budget.tab_rov'), url: widgets_bubbletree_path(tax_rov)} if tax_rov
    tabs << { title: t('public.towns.budget.tab_sankey'), url: get_sankey_path(sankey.id) } if sankey

    tabs.first[:cname] = 'active'
    tabs
  end

  def set_town
    @town = Town.find(params[:town_id])
  end
  def test_town?
    @town.is_test?
  end

  def get_town_items_hash (town_object)
    @town = town_object
    town = nil
    town = town_object.title unless town_object.blank?
    # taxonomy_rot = TaxonomyRot.get_rot_by_owner_city(town).last
    # taxonomy_rov = TaxonomyRov.get_rov_by_owner_city(town).last
    taxonomy = Taxonomy.owned_by(town_object.to_s).first
    calendar = Calendar.get_calendar_by_town(town)
    indicate_taxonomy = Indicate::Taxonomy.get_indicate_by_town(town_object).last
    # programs = Programs::TargetedProgram.first
    programs = Programs::TargetedProgram.by_town(@town)
    result = []
    result << get_budget_compare_hash('budget_compare')
    result << get_indicate_hash(indicate_taxonomy, 'indicators')
    result << get_taxonomy_rot_hash(taxonomy, 'budget')
    result << get_calendar_hash(calendar, 'calendar')
    # result << get_taxonomy_rov_hash(taxonomy_rov,'budget')
    result << get_repair_hash('repair')
    result << get_programs_hash(programs, 'programs')
    # result << get_key_docs_hash('key_docs')
    # result << get_prozorro_hash('prozoroo')
    # result << get_edata_hash('edata')
    # result << get_purchase_hash('purchase')
    # result << get_keys_hash('keys')

    result.compact
  end


  def get_budget_compare_hash(name)
    get_item_hash(img_url(name),title_for_portfolio(name),compare_taxonomies_compare_budget_path(@town),name)
  end

  def get_taxonomy_rot_hash(taxonomy_rot,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#',name) do
      unless taxonomy_rot.nil?
        return {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> public_budget_files_path(@town),'name' => name}
      end
    end
  end

  def get_indicate_hash(indicate,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#',name) do
      unless indicate.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> indicate_taxonomies_town_profile_path(@town),'name' => name}
      end
    end
  end

  def get_taxonomy_rov_hash(taxonomy_rov,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#',name) do
      unless taxonomy_rov.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> taxonomies_town_profile_path(@town),'name' => name}
      end
    end
  end

  def get_calendar_hash(calendar,name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#',name) do
      unless calendar.nil?
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> calendar_town_profile_path(calendar),'name' => name}
      end
    end
  end

  def get_keys_hash(name)
    get_item_hash(img_url(name), title_for_portfolio('no_data'), '#',name) do
      if @town.key_indicate_map_indicators
        {'title' => title_for_portfolio(name), 'img_src' => img_url(name), 'url'=> key_indicate_map_indicators_get_town_profile_path(@town),'name' => name}
      end
    end
  end

  def get_programs_hash(name,programs)
    get_item_hash(img_url(name), title_for_portfolio(name), programs_targeted_program_path(programs),name) unless programs.nil?
  end

  def get_item_hash(item_img_src,item_title,item_url,name)
    result = yield if block_given?
    unless result.nil?
      return result
    end
    unless item_url == "#"
      {'title' => item_title, 'img_src' => item_img_src, 'url'=> item_url,'name' => name}
    end

  end

  def get_repair_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), repairing_map_path,name) #(6, @town))
  end

  def get_key_docs_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), public_documents_town_profile_path(@town),name)
  end

  def get_prozorro_hash(name)
    get_item_hash("public/" + name + ".png", title_for_portfolio(name), 'http://bi.prozorro.org/sense/app/fba3f2f2-cf55-40a0-a79f-b74f5ce947c2/sheet/HbXjQep/state/analysis',name)
  end
  def get_edata_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), 'http://www.spending.gov.ua/',name)
  end
  def get_purchase_hash(name)
    get_item_hash(img_url(name), title_for_portfolio(name), 'https://ips.vdz.ua/ua/purchase_search.htm',name)
  end

  def img_url (item)
    "new_design/icons/" + item + ".svg"
  end

  def title_for_portfolio (item)
    I18n.t('public.towns.portfolio.' + item)
  end
end