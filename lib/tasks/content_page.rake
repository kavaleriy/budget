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

  desc "Create about page"
  task :create_about_page => :create_menu_nav do
    about_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::ABOUT_US).first
    page_obj = ContentManager::PageContainer.new({header: 'About us',content: 'About description',
                                                  alias: 'about',p_id: about_menu})
    page_obj.save
  end

  desc "Create budget page"
  task :create_budget_system_page => :create_about_page do
    budget_system_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::BUDGET_SYSTEM).first
    page_arr = %w( Budget_system Budget_process Glossary)
    page_arr.each do |page|
      page_obj = ContentManager::PageContainer.new({header: page,content: "#{page} content",
                                                alias: page ,p_id: budget_system_menu})

      binding.pry
      page_obj.save
    end
  end

  desc "Create visualisation page"
  task :create_visualisation_page => :create_budget_system_page do
    visualisation_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::VISUALISATION).first
    page_arr = %w( Budget_system Budget_process Glossary)
    page_arr.each do |page|
      page_obj = ContentManager::PageContainer.new({header: page,content: "#{page} content",
                                                    alias: page, p_id: visualisation_menu})
      page_obj.save
    end
  end

end