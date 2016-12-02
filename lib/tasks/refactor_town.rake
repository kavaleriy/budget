namespace :refactor_town do

  task calendar: :environment do
    counter = 0
    calendars_with_town = Calendar.where(:town.ne => nil)
    calendars_without_town = Calendar.where(town: nil)
    Calendar.where(:town.ne => nil).each_with_index do |cal, index|
      town = Town.by_title(cal.town)
      unless town.nil?
        counter += 1
        cal.town_model = town
        cal.save(validate: false)
      else
        puts "calendar #{cal.title} was not set new town"
        Rails.logger.debug "calendar #{cal.title} was not set new town"
      end

    end

    Rails.logger.debug "Calendars with town #{calendars_with_town.size}"
    Rails.logger.debug "Calendars without town #{calendars_without_town.size}"
    Rails.logger.debug "in #{counter} calendars was set town model"

  end

  task taxonomy: :calendar do
    counter = 0
    tax_with_town = Taxonomy.where(:owner.ne => nil)
    tax_without_town = Taxonomy.where(owner: nil)

    tax_with_town.each_with_index do |tax|
      town = Town.by_title(tax.owner)

      unless town.nil?
        counter += 1
        tax.town = town
        tax.save(validate: false)
      else
        puts "taxonomy #{tax.owner} was not set new town"
        Rails.logger.debug "taxonomy #{tax.owner} was not set new town"
      end
    end

    Rails.logger.debug "Taxonomy with town #{tax_with_town.size}"
    Rails.logger.debug "Taxonomy without town #{tax_without_town.size}"
    Rails.logger.debug "in #{counter} taxonomies was set new town"
  end

  task user: :taxonomy do
    counter = 0
    user_with_town = User.where(:town.ne => nil)
    user_without_town = User.where(town: nil)
    user_with_town.each do |user|
      town = Town.by_title(user.town)
      unless town.nil?
        counter += 1
        user.town_model = town
        user.save(validate: false)
      else
        puts "user #{user.email} was not set new town"
        Rails.logger.debug "user #{user.email} was not set new town"
      end
    end
    Rails.logger.debug "user with town #{user_with_town.size}"
    Rails.logger.debug "user without town #{user_without_town.size}"
    Rails.logger.debug "in #{counter} users was set new town"
  end

  task parse_new_koatuu: :user do
    require 'roo'

    xls = Roo::Excelx.new("db/koatuu/decomunization/KOATU_02112016.xlsx")
    xls.default_sheet = xls.sheets.first

    2.upto(xls.last_row) do |line|

      koatuu = xls.cell(line,'A').to_s.gsub('.0', '').rjust(10, '0')

      note = xls.cell(line,'B') || ''
      title = extract_name (xls.cell(line,'D')) || ''

      b3 = koatuu[2]
      b6 = koatuu[5]

      level = if b3 == '0' and b6 == '0'
        Town::AREA_LEVEL
      elsif b3.index(/[23]/) and b6 == '0' and koatuu.match(/.0000000/).nil?
        Town::REGION_LEVEL
      elsif koatuu.index('10100000')
        Town::CITY_LEVEL # head of area
      elsif note.index(/[М]/)
        Town::TOWN_LEVEL
      elsif note.index(/[Т]/)
        Town::VILLAGE_LEVEL
      else
        Town::WITHOUT_LEVEL
      end

      town = Town.find_or_create_by(:koatuu => koatuu)
      town.title = title.to_s
      town.note = note
      town.level = level if town.level.blank?

      town.save
    end

    # calculate area title
    Town.areas.each do |area|
      area.mark_delete = false
      area.save
    end
    Town.each do |town|
      town.mark_delete = false
      unless town.level == 1
        next if town.koatuu.blank? || town.koatuu == '8000000000'
        area_title = Town.areas(town.koatuu.slice(0, 2)).first
        if town.valid?
          # TODO refactor area_title
          town.area_town = area_title
          town.area_title = area_title

        else
          town.mark_delete = true
        end
        town.save
      end
    end
  end


end
