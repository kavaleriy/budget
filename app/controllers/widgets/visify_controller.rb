class Widgets::VisifyController < Widgets::WidgetsController
  before_action :set_budget_file
  #before_action :set_taxonomy_file

  MAX_NODES_PER_LEVEL = 8

  def get_sunburst_data
    render json: get_sunburst_tree
  end

  def get_icicle_data
    render json: get_icicle_tree
  end

  def get_bubbletree_data
    render json: get_bubble_tree
  end

  private

  def get_bubble_tree
    tree = @budget_file.get_tree
    return if tree.nil?

    get_bubble_tree_item(tree, { 'color' => 'green', 'icon' => '/assets/icons/pig.svg' })
  end

  def get_bubble_tree_item(item, info)
    #cut_amount = (tree[:max].abs - tree[:min].abs) * 0.0005
    amount = (item['amount'][@sel_year][@sel_month] rescue 0)

    return nil if amount == 0

    node = {
        'size' => amount,
        'amount' => amount,
        'history' => item['amount'],
        'label' => item['key'],
    }

    if info
      node['label'] = info['title'] unless info['title'].nil? or info['title'].empty?
      node['icon'] = info['icon'] unless info['icon'].nil? or info['icon'].empty?
      node['color'] = info['color'] unless info['color'].nil? or info['color'].empty?
      node['description'] = info['description'] unless info['description'].nil? or info['description'].empty?
    end

    # binding.pry if node['label'] == "5000"

    if item['children'].nil? || item['children'].length < 2
      node['color'] = '#a8bccc'
    elsif node['color'].nil?
      node['color'] = '#265f91'
    end

    child_count = if item['children'].nil?
                    0
                  else
                    item['children'].reject{|c| ((c['amount'][@sel_year][@sel_month].to_i rescue 0) || 0) == 0 }.length
                  end

    unless item['children'].nil?
      node['children'] = []

      item['children'].each { |child_node|
        explanation = if child_node['key'].nil?
          {}
        else
          @taxonomy.explanation[child_node['taxonomy']][child_node['key']]
        end

        ti = get_bubble_tree_item(child_node, explanation) # if child_node[:amount].abs > cut_amount
        unless ti.nil?
          if node['children'].length >= MAX_NODES_PER_LEVEL && child_count > MAX_NODES_PER_LEVEL + 2
            unless ti['amount'].nil? || ti['amount'] == 0
              if node['children'][MAX_NODES_PER_LEVEL].nil?
                node['children'][MAX_NODES_PER_LEVEL] =
                    { 'label' => 'Агреговано',
                      'description' => '',
                      'amount' => ti['amount'],
                      'size' => ti['amount'],
                      'color' => 'green',
                      'icon' => '<i class="fa fa-folder-open-o"></i>'
                    }
                node['children'][MAX_NODES_PER_LEVEL]['children'] = []
              end

              node['children'][MAX_NODES_PER_LEVEL]['amount'] += ti['amount']
              node['children'][MAX_NODES_PER_LEVEL]['size'] += ti['amount']
              node['children'][MAX_NODES_PER_LEVEL]['children'] << ti
            end
          else
            node['children'] << ti unless ti.nil?
          end
        end
      }
    end

    node unless node['amount'].nil?
  end

  def get_sunburst_tree
    get_bubble_tree
  end

  #def get_icicle_tree
  #  get_icicle_tree_item(@budget_file.tree, { 'title' => 'Всього', 'color' => 'green' })
  #end
  #
  #def get_icicle_tree_item(item, info)
  #  cut_amount = (@budget_file.meta_data[:max].abs - @budget_file.meta_data[:min].abs) * 0.0005
  #
  #  key = "#{item[:taxonomy]} #{item[:key]}"
  #  if item[:children].nil?
  #    node = item[:amount].abs
  #  else
  #    node = {}
  #    item[:children].each { |child_node|
  #      child_key = "#{child_node[:taxonomy]} #{child_node[:key]}"
  #      node[child_key] = get_icicle_tree_item(child_node, @budget_file.tree_info[child_node[:taxonomy]][child_node[:key]])
  #    }
  #  end
  #
  #  node
  #end
  #
  def set_budget_file
    @sel_year = '0'
    @sel_month = '0'
    @range = {}

    @budget_file = BudgetFile.where(:id => visify_params[:file_id]).first
    @taxonomy = Taxonomy.where(:id => visify_params[:file_id]).first || @budget_file.taxonomy
    @budget_file = @taxonomy if @budget_file.nil?

    range = {}
    @budget_file.get_range.each{ |item| item.each{ |k, v| range[k] = v } }
    @range = range.sort_by{|k,v| k.to_i}

    @sel_year = visify_params[:year] || @range.last[0]
    @sel_month = visify_params[:month] || @range.last[1].first
  rescue => e
    logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  end

  def visify_params
    params.permit(:file_id, :year, :month)
  end

end
