class Widgets::TownProfileController < Widgets::WidgetsController

  # after_filter :allow_iframe, only: [:portfolio]

  before_action :set_town,
                :except => [ :budget_files_by_taxonomies,
                                       :sankey_by_taxonomies,
                                       :show_indicates ]

  def budget_files
    # this action return hash for navigation panel
    # first element of hash is: first budget profit url(by @town) and budget profit title
    # second element of hash is: first budget outlay url(by @town) and budget outlay title
    # third element of hash is: interrelation url from budget profit and budget outlay and interrelation title
    # set first element of hash is active
    @tabs = []

    taxonomy_rot = TaxonomyRot.active_or_first_by_town(@town)
    taxonomy_rov = TaxonomyRov.active_or_first_by_town(@town)

    sankey_url = widgets_sankey_by_taxonomies_path(taxonomy_rot.id,taxonomy_rov.id) unless taxonomy_rov.nil? || taxonomy_rot.nil?

    @tabs << { title: t('public.towns.budget.tab_rot'), url: widgets_bubbletree_path(taxonomy_rot.id)} if taxonomy_rot
    @tabs << { title: t('public.towns.budget.tab_rov'), url: widgets_bubbletree_path(taxonomy_rov.id)} if taxonomy_rov
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
    # @sankey.owner = Taxonomy.find(params[:tax_rot]).owner
    @switch_plan_fact = Taxonomy.check_switch_plan_fact(params[:tax_rot],params[:tax_rov])
    render partial: 'sankey', :locals => { sankey: @sankey }
  end

  def portfolio
    # @town = Town.find(params[:town_id])
    @town_items = get_town_items_hash
    respond_to do |format|
      format.js
      format.html
    end
  end

  # def budget_compare
  # end

  private

  def allow_iframe
    response.headers['x-frame-options'] = 'ALLOWALL'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  end

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

  def get_town_items_hash
    taxonomy = Taxonomy.active_or_first_by_town(@town)
    calendar = Calendar.get_calendar_by_town(@town)
    indicate_taxonomy = Indicate::Taxonomy.get_indicate_by_town(@town).last
    programs = Programs::TargetedProgram.by_town(@town).first
    e_data = Modules::Classifier.by_koatuu(@town.koatuu).first
    repairs = Repairing::Repair.repair_json_by_town(@town.id.to_s)

    result = []
    result << get_item_hash('budget_compare', compare_taxonomies_compare_budget_path(@town))
    result << get_item_hash('indicators', indicate_taxonomies_town_profile_path(@town)) unless indicate_taxonomy.nil?
    result << get_item_hash('budget', public_budget_files_path(@town)) unless taxonomy.nil?
    result << get_item_hash('calendar', calendar_town_profile_path(calendar)) unless calendar.nil?
    result << get_item_hash('e_data', modules_classifier_search_data_path(@town)) unless e_data.nil?
    result << get_item_hash('programs', programs_town_targeted_programs_path(@town)) unless programs.nil?
    # TODO: get url with repairing_frame_with_town_path(zoom: 9,town_id: params[:town_id]) and setting logic for this url
    # WARN: script in _frame.html.haml don`t use maps#geo_json
    result << get_item_hash('repair', repairing_map_show_town_path(@town)) unless repairs['features'].blank?

    result.compact
  end

  def get_item_hash(title, url)
    {
        'img_src' => img_url(title),
        'title' => title_for_portfolio(title),
        'url'=> url,
        'name' => title
    }
  end

  def img_url (item)
    "new_design/icons/" + item + ".svg"
  end

  def title_for_portfolio (item)
    I18n.t('public.towns.portfolio.' + item)
  end
end
