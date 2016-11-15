namespace :refactor_town do

  task clear_no_valid_town: :environment do
    Town.where(:title.in => ['', nil], :koatuu.in => [nil, '']).each do |town|
      town.destroy
    end
  end

  task calendar: :environment do
    counter = 0
    calendars_with_town = Calendar.where(:town.ne => nil)
    calendars_without_town = Calendar.where(town: nil)
    Calendar.where(:town.ne => nil).each_with_index do |cal, index|
      town = Town.by_title(cal.town)
      unless town.nil?
        counter += 1
        cal.town_model = town
        cal.save
      else
        puts "calendar #{cal.title} was not set new town"
        Rails.logger.debug "calendar #{cal.title} was not set new town"
      end

    end

    Rails.logger.debug "Calendars with town #{calendars_with_town.size}"
    Rails.logger.debug "Calendars without town #{calendars_without_town.size}"
    Rails.logger.debug "in #{counter} calendars was set town model"

  end

  task taxonomy: :environment do
    counter = 0
    tax_with_town = Taxonomy.where(:owner.ne => nil)
    tax_without_town = Taxonomy.where(owner: nil)

    tax_with_town.each_with_index do |tax|
      town = Town.by_title(tax.owner)

      unless town.nil?
        counter += 1
        tax.town = town
        tax.save
      else
        puts "taxonomy #{tax.owner} was not set new town"
        Rails.logger.debug "taxonomy #{tax.owner} was not set new town"
      end
    end

    Rails.logger.debug "Taxonomy with town #{tax_with_town.size}"
    Rails.logger.debug "Taxonomy without town #{tax_without_town.size}"
    Rails.logger.debug "in #{counter} taxonomies was set new town"
  end

  task user: :environment do
    counter = 0
    user_with_town = User.where(:town.ne => nil)
    user_without_town = User.where(town: nil)
    user_with_town.each do |user|
      town = Town.by_title(user.town)
      unless town.nil?
        counter += 1
        user.town_model = town
        user.save
      else
        puts "user #{user.email} was not set new town"
        Rails.logger.debug "user #{user.email} was not set new town"
      end
    end
    Rails.logger.debug "user with town #{user_with_town.size}"
    Rails.logger.debug "user without town #{user_without_town.size}"
    Rails.logger.debug "in #{counter} users was set new town"
  end

  # task parse_koatuu: :environment do
  #
  # end


end
