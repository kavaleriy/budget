class Widgets::VisifyController < Widgets::WidgetsController
  include ControllerCaching

  before_action :set_locale

  before_action :set_budget_file
  before_action :set_params, :except => [:get_bubbletree_nodedata]

  MAX_NODES_PER_LEVEL = 100

  def type
    render :partial => 'widgets/visify/' + params[:type]
  end

  def get_bubbletree_data
    # result = use_cache do
    levels = params[:levels] ? params[:levels].split(",") : []
    result = get_bubble_tree(levels)
    # end

    render json: result
  end

  def get_bubblesubtree_with_fact
    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    title =
        if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
          ''
        else
          @taxonomy.explanation[taxonomy][key][:title] || key
        end

    filter = ['fond', taxonomy]

    rows = @taxonomy.get_plan_fact_rows
    tree_rows = @taxonomy.get_subrows(taxonomy, key, filter, rows[:plan]) || {}
    tree_fact_rows = @taxonomy.get_subrows(taxonomy, key, filter, rows[:fact]) || {}

    tree = @taxonomy.create_tree_sceleton tree_rows, filter
    tree_fact = @taxonomy.create_tree_sceleton tree_fact_rows, filter

    tree = create_tree_item_with_fact tree, tree_fact

    render json: get_bubble_tree_item_with_fact(tree, {  'title' => title, 'color' => 'green', 'icon' => '/assets/icons/open_folder.svg' })
  end

  def create_tree_item_with_fact(items, items_fact, key = I18n.t('mongoid.taxonomy.in_total'))
    node = {
        'fact_amount' => items_fact[:amount],
        'amount' => items[:amount],
        'key' => key,
        'taxonomy' => items[:taxonomy]
    }

    children = items.keys.reject{|k| k == :amount || k == :taxonomy }

    unless children.empty?
      node['children'] = []
      children.each { |item_key|
        if items_fact[item_key].nil?
          items_fact[item_key] = {}
          items_fact[item_key][:amount] = 0
        end
        node['children'] << create_tree_item_with_fact(items[item_key], items_fact[item_key], item_key)
      }
    end
    node
  end

  def get_bubblesubtree
    # http://localhost:3000/widgets/visify/get_bubblesubtree/551e4e197562751064010000/2015/0/kvk/10:48380

    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    title =
        if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
          ''
        else
          @taxonomy.explanation[taxonomy][key][:title] || key
        end

    filter = ['fond', taxonomy]
    tree = @budget_file.get_subtree(taxonomy, key, filter) || {}

    render json: get_bubble_tree_item(tree, {  'title' => title, 'color' => 'green', 'icon' => '/assets/icons/open_folder.svg' })
  end

  def get_bubbletree_nodedata
    taxonomy = visify_params[:taxonomy]
    key = visify_params[:key]

    description =
      if @taxonomy.explanation[taxonomy].nil? or @taxonomy.explanation[taxonomy][key].nil?
        ''
      else
        @taxonomy.explanation[taxonomy][key][:description]
      end

    render json: { 'description' => description }
  end

  def get_attachments
    render json: { 'attachments' => @taxonomy.taxonomy_attachments }
  end

  def get_visify_level
    taxonomy = visify_params[:taxonomy]

    render json: @taxonomy.get_level(taxonomy)
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def get_bubble_tree levels
    tree = @budget_file.get_tree levels
    return if tree.nil?

    get_bubble_tree_item(tree, { 'color' => 'green', 'icon' => '/assets/icons/pig.svg' })
  end

  def get_bubble_tree_item(item, info)

    node = {
        'amount' => item['amount'],
        'label' => item['key'],
        'key' => item['key'],
        'taxonomy' => item['taxonomy']
    }

    item = item['children'][0] if item['children'] and 1 == item['children'].reject{|c| ((c['amount'][@data_type.to_sym][@sel_year][@sel_month]['total'].to_i rescue 0) || 0) == 0 }.length

    if info
      node['label'] = info['title'] unless info['title'].blank?
      node['icon'] = info['icon'] unless info['icon'].blank?
      node['color'] = info['color'] unless info['color'].blank?
      # node['description'] = info['description'] unless info['description'].nil? or info['description'].empty?
    end

    if @taxonomy.recipients and node['taxonomy'] == @taxonomy.recipients_column.to_s
      recipient = @taxonomy.recipients.where(code: node['key']).first
      node['recipient_amount'] = recipient.amount unless recipient.blank? or recipient.amount == 0
    end

    # colors = ['#1f77b4','#ff7f0e','#2ca02c','#d62728','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf']
    if item['children'].nil?
      # color = colors.sample
      node['color'] = '#a8bccc'
    elsif node['color'].nil?
      # node['color'] = '#265f91'
    end

    # child_count = if item['children'].nil?
    #                 0
    #               else
    #                 item['children'].reject{|c| ((c['amount'][@data_type.to_sym][@sel_year][@sel_month]['total'].to_i rescue 0) || 0) == 0 }.length
    #               end

    if item['children']
      node['children'] = []

      item['children'].each { |child_node|
        explanation = ( @taxonomy.explanation[child_node['taxonomy']][child_node['key']] rescue {} )

        ti = get_bubble_tree_item(child_node, explanation) # if child_node[:amount].abs > cut_amount
        unless ti.nil?
          node['children'] << ti
        end
      }
    end
    node
  end

  def set_budget_file
    @budget_file = BudgetFile.where(:id => visify_params[:file_id]).first
    @taxonomy = Taxonomy.where(:id => visify_params[:file_id]).first || @budget_file.taxonomy

    @table_caption = (@taxonomy.is_a? TaxonomyRot) ? 'Види доходів' : 'Напрямок видатків'

    if @budget_file.nil?
      @budget_file = @taxonomy
      @types_count = @taxonomy.budget_files.group_by{|f| f.data_type}.count
    else
      @data_type = @budget_file.data_type
      @types_count = 1
    end
    @data_type = 'plan' if @data_type.blank?

    @levels = @taxonomy.columns.keys
    @file_type = @taxonomy._type

    town_title = @taxonomy.owner.split(',')
    @town = Town.where(title: town_title[0])
    @town = Town.where(area_title: town_title[1].squish) if town_title[1]
    @town = @town.first
  end

  def set_params
    @sel_year = '0'
    @sel_month = '0'

    @range = {}
    range = {}
    @budget_file.get_range.each{ |item| item.each{ |k, v| range[k] = v } }
    @range = range.sort_by{|k,v| k.to_i}

    @sel_year = visify_params[:year] || @range.last[0]
    @sel_month = visify_params[:month] || @range.last[1].first

    @fond_codes = Taxonomy.fond_codes(params['locale'] || 'uk')

    @amounts = build_amounts_list()

  rescue => e
    logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  end

  def visify_params
    params.permit(:file_id, :year, :month, :key, :taxonomy, :levels, :amount_type)
  end

  protected

  def build_amounts_list
    amounts = []

    amounts << { title: 'Гривня', amount: 1 }

    usd_rate = Currency.find_or_create_by!(:short_title => 'USD').rates.where(:year => @sel_year).last
    amounts << { title: t('amount_usd'), amount: usd_rate.rate, recalc_per: true } if usd_rate and usd_rate.rate

    counters = @town.counters
    unless counters.nil?
      amounts << { title: t('amount_citizens'), amount: counters.citizens, amount_pre: t('amount_citizens_short'),  } if counters.citizens
      amounts << { title: t('amount_house_holdings'), amount_pre: t('amount_house_holdings_short'), amount: counters.house_holdings } if counters.house_holdings
      amounts << { title: t('amount_square'), amount_pre: t('amount_square_short'), amount: counters.square } if counters.square
    end

    amounts
  end


end
