#encoding: utf-8

namespace :koatuu do

    desc "Load KOATUU from file"
  task :load => :environment do

    require 'roo'

    xls = Roo::Excelx.new("db/koatuu/koatuu_01042014.xlsx")
    xls.default_sheet = xls.sheets.first

    2.upto(xls.last_row) do |line|
      code = xls.cell(line,'A').to_s.gsub('.0', '').rjust(10, '0')

      note = xls.cell(line,'B') || ''
      title = extract_name (xls.cell(line,'C')) || ''

      b3 = code[2]
      b6 = code[5]

      if b3 == '0' and b6 == '0'
        level = 1
      elsif b3.index(/[23]/) and b6 == '0' and code.match(/.0000000/).nil?
        level = 2
      elsif code.index('10100000')
        level = 13 # head of area
      elsif note.index(/[М]/)
        level = 3
      elsif note.index(/[Т]/)
        level = 31
      end

      puts code

      koatuu = Town.find_or_create_by(:koatuu => code).
          update({ title: title, note: note, level: level })
    end


    # post-process
    Town.where(:koatuu => '8000000000').first.update( { :level => 13, :area_title => "Київська область"} ) # kyiv
    # Town.delete_all(:koatuu => Regexp.new("^01.*"))

    # Town.delete_all(:koatuu => '8500000000') # Sevastopol

    Town.delete_all(:level => nil)

    # calculate area title
    Town.each do |town|
      unless town.level == 1
        next if town.koatuu.blank? || town.koatuu == '8000000000'
        area_title = Town.areas(town.koatuu.slice(0, 2)).first
        town.update( area_title: area_title )
      end
    end

  end

  private
  def self.extract_name name
    index = name.index('/')
    name = name.slice(0, index) if index
    if /^М\./ =~ name
      name = $'.mb_chars.capitalize
    else
      name.mb_chars.capitalize
    end
    # name.mb_chars.gsub(/ ОБЛАСТЬ$/, '').gsub(/ РАЙОН$/, '').capitalize
  end


  # =====================================================================================================
  desc "Set geo-data from OSM"
  task :update_coordinates => :environment do
    Town.each do |town|
      town.update(:coordinates => get_town_coordinates("#{town.title}, #{town.area_title}")) if town.coordinates.blank?
    end
  end

  desc "Add center and bounds to Ukraine regions"
  task :add_bounds => :environment do
    require 'csv'

    csv_text = File.read('db/koatuu/koatuu_bounds_center.csv')
    csv = CSV.parse(csv_text, :headers => true, :col_sep => ";")
    csv.each do |row|
      Town.where(:koatuu => row['koatuu']).first.update( { :bounds => eval(row['bounds']), :center => eval(row['center'])} )
    end
  end

  private
    def get_town_coordinates location
      Geocoder.coordinates(location)
    end

end
