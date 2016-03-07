namespace :content_page do
  desc "Create menu_nav"
  task create_menu_nav: :environment do
    constants_hash = ContentManager::PageContainer.get_constant_to_h
    constants_hash.each do |key,value|
      page = ContentManager::PageContainer.new({header: key,content: "#{key} description",
                                         alias: value})
      page.save
    end
  end

  desc "Create visualisation page"
  task :create_about_page => :create_menu_nav do
    about_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::ABOUT_US).first
    page = ContentManager::PageContainer.new({header: 'About us',content: 'About description',
                                              p_id: about_menu})
    page.save
  end
end