include Rails.application.routes.url_helpers
namespace :content_page do
  desc "Create menu_nav"
  task create_menu_nav: :environment do
    constants_hash = ContentManager::PageContainer.get_constant_to_h
    index = 0
    head_arr = %w(about bud_sys visual public_control)
    constants_hash.each do |key,value|
      page = ContentManager::PageContainer.new({header: get_title(head_arr[index]) ,content: "#{key} description",
                                                alias: value})
      page.save
      index += 1
    end
  end

  desc "Create about page"
  task :create_about_page => :create_menu_nav do
    about_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::ABOUT_US).first
    page_obj = ContentManager::PageContainer.new({header: '.about', content: 'About description',
                                                  alias: 'about',p_id: about_menu.id})
    page_obj.save
  end

  desc "Create budget page"
  task :create_budget_system_page => :create_about_page do
    head_arr = %w(bud_sys_ua bud_proc bud_glos)
    budget_system_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::BUDGET_SYSTEM).first
    head_arr.each do |page|
      page_obj = ContentManager::PageContainer.new({header: get_title(page),content: "#{page} content",
                                                alias: page ,p_id: budget_system_menu.id})
      page_obj.save
    end
  end

  desc "Create visualisation page"
  task :create_visualisation_page => :create_budget_system_page do
    visualisation_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::VISUALISATION).first
    page_arr = %w( grom_budget compare_budget kpi budget budget_cal towns_programs budget_at_map)
    page_arr.each do |page|
      page_obj = ContentManager::PageContainer.new({header: get_title(page),content: "#{page} content",
                                                    alias: page, p_id: visualisation_menu.id})
      page_obj.save
    end
  end

  desc "Create People control page"
  task :create_people_control_page => :create_visualisation_page do
    budget_system_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::PUBLIC_CONTROL).first
    page_arr = %w( library history_success )
    page_arr.each do |page|
      link = ''
      if(page == 'library')
        link = library_books_path
      end
      page_obj = ContentManager::PageContainer.new({header: get_title(page),content: "#{page} content",
                                                link: link,alias: page ,p_id: budget_system_menu.id})
      page_obj.save
    end
  end

  def get_title(head)
    "layouts.navbar.#{head}"
  end
end