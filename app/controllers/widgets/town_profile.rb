class Widgets::TownProfile < Widgets::WidgetsController

  def portfolio
    line_items = get_town_items(@town)
  end

  def get_town_items town_object
    @town = town_object
    town = nil
    town = @town.title unless @town.blank?
    # @budgets = Taxonomy.where(:owner => town)
    # @total_amounts = {}
    # @budgets.each{|budget|
    #   @total_amounts[budget._type] = budget.get_total_amounts
    # }

    town_items = []
    # town_items.push('budget') if Taxonomy.where(:owner => town).first

    town_items.push('programs') if Programs::Town.where(:name => town).first
    town_items.push('calendar') if Calendar.where(:town => town).first
    # @town_items.push('sankey') if Sankey.where(:owner => town).first
    town_items.push('repair')
    town_items.push('key_docs')
    if @town.blank?
      town_items.push('keys')
      @town = Town.new(:id => 'test',
                       :title => 'Демонстрація типового профілю міста',
                       :description => 'Розділ містить короткі відомості про місто, особливості бюджету і т.п...',
                       :links => '<a href="http://www.openbudget.in.ua" target="_blank" rel="nofollow">http://www.openbudget.in.ua/</a>')
      town_items.push('indicators') if Indicate::Taxonomy.where(:town => nil)
    else
      town_items.push('keys') if @town.key_indicate_map_indicators
      town_items.push('indicators') if Indicate::Taxonomy.where(:town => @town).first
    end
    town_items
  end
end