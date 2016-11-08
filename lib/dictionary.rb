module Dictionary

  class TlTerra

    FILE_NAME = 'db/tl_terra.csv'

    def self.items
      def self.get_items
        file_name = 'db/tl_terra.csv'
        items = {}
        CSV.foreach(FILE_NAME, {:headers => true, :col_sep => ";"}) do |row|
          id, obl, title = row[0], row[1], row[2]
          items[obl] = { } if items[obl].nil?
          items[obl][id] = title
        end
        items
      end

      @items = get_items if @items.nil?
      @items
    end

    def self.areas
      def self.get_areas
        items = {}
        CSV.foreach(FILE_NAME, {:headers => true, :col_sep => ";"}) do |row|
          id, obl, title = row[0], row[1], row[2]
          next unless id == '001'

          items[obl] = title
        end

        items
      end
      @areas = get_areas
    end

    def self.towns area
      items[area]
    end

  end
end
