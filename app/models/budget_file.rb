class BudgetFile
  include Mongoid::Document

  field :owner_email, type: String

  field :title, type: String
  field :path, type: String

  # source data
  field :rows, :type => Array

  # list of taxonomies for tree levels
  belongs_to :taxonomy, autosave: true

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash


  def import file_name, table
    self.taxonomy = get_taxonomy file_name, table[:cols]

    self.rows = table[:rows].map { |row|
      self.taxonomy.readline(row)
    }.reject { |c| c.nil? }.flatten

    self.rows.each do |row|
      row.keys.reject{|key| key == 'amount'}.each do |key|
        self.taxonomy.explain(key, row[key])
      end
    end

    self.tree = create_tree
  end

  protected

  def get_taxonomy file_name, columns
    Taxonomy.get_taxonomy(file_name, columns)
  end


  def create_tree
    tree = { :amount => 0 }

    min = nil
    max = 0

    self.rows.each do |row|
      next unless row['_month'].nil? || row['_month'] == '0'

      node = tree
      node[:amount] += row['amount']
      self.taxonomy.columns.keys.each { |taxonomy_key|
        taxonomy_value = row[taxonomy_key]

        if node[taxonomy_value].nil?
          node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => row['amount'] }
        else
          node[taxonomy_value][:amount] += row['amount']
        end

        min = node[taxonomy_value][:amount] if min.nil? || node[taxonomy_value][:amount].abs < min
        max = node[taxonomy_value][:amount] if node[taxonomy_value][:amount].abs > max
        node = node[taxonomy_value]
      }
    end

    self.meta_data = { :min => min, :max => max}

    create_tree_item(tree)
  end

  def create_tree_item(items, key = 'Всього')
    node = {
        'amount' => items[:amount],
        'key' => key,
        :taxonomy => items[:taxonomy]
    }

    children = items.keys.reject{|k| k == :amount || k == :taxonomy }

    unless children.empty?
      node['children'] = []
      children.each { |item_key|
        node['children'] << self.create_tree_item(items[item_key], item_key)
      }
    end

    node
  end

end
