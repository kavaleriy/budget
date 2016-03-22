include Rails.application.routes.url_helpers
include I18n
namespace :content_page do
  desc "Remove all content page"
  task remove_page: :environment do
    ContentManager::PageContainer.all.each do |page|
      page.destroy
    end
  end

  desc "Create menu_nav"
  task create_menu_nav: :remove_page do
    constants_hash = ContentManager::PageContainer.get_constant_to_h
    index = 0
    head_arr = %w(about bud_sys visual public_control)
    head_arr_en = ['About', 'Budget system', 'Visualisation', 'Public control']
    constants_hash.each do |key,value|
      create_page_cont(head_arr_en[index], I18n.t(get_title(head_arr[index])), "#{key} description",'',value,nil)
      index += 1
    end
  end

  desc "Create about page"
  task :create_about_page => :create_menu_nav do
    about_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::ABOUT_US).first
    create_page_cont('About','Про нас','About description','Про нас опис' ,'about',about_menu.id)
  end

  desc "Create budget page"
  task :create_budget_system_page => :create_about_page do
    index = 0
    head_arr_en = ['Ukraine budget system', 'Budget process', 'Glossary']
    head_arr = %w(bud_sys_ua bud_proc bud_glos)
    budget_system_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::BUDGET_SYSTEM).first
    head_arr.each do |page|

      create_page_cont(head_arr_en[index],I18n.t(get_title(page)),"#{page} content","#{I18n.t(get_title(page))} опис" ,page,
                       budget_system_menu.id)
      index += 1
    end
  end

  desc "Create visualisation page"
  task :create_visualisation_page => :create_budget_system_page do
    index = 0
    head_arr_en = ['People budget', 'Compare budget', 'Kpi', 'Budget', 'Budget calendar',
                   'Towns programs','Budget at map']
    visualisation_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::VISUALISATION).first
    page_arr = %w( grom_budget compare_budget kpi budget budget_cal towns_programs budget_at_map)
    page_arr.each do |page|
      create_page_cont(head_arr_en[index],I18n.t(get_title(page)),"#{page} content","#{I18n.t(get_title(page))} опис" ,page,
                       visualisation_menu.id)
    index += 1
    end
  end

  desc "Create People control page"
  task :create_people_control_page => :create_visualisation_page do
    index = 0
    head_arr_en = ['Library', 'History success']
    budget_system_menu = ContentManager::PageContainer.get_parent_menu(ContentManager::PageContainer::PUBLIC_CONTROL).first
    page_arr = %w( library history_success )
    page_arr.each do |page|
      link = ''
      if(page == 'library')
        link = library_books_path
      end
      create_page_cont(head_arr_en[index],I18n.t(get_title(page)),"#{page} content","#{I18n.t(get_title(page))} опис" ,page,
                            budget_system_menu.id,link)
      index += 1
    end
  end



  def get_title(head)
    "layouts.navbar.#{head}"
  end

  def create_page_cont(title_en,title_uk,desc_en,desc_uk,as,p_id,link = '')
    page_obj = ContentManager::PageContainer.new( :locale_data =>{:en => {header: title_en, content: desc_en},
                                                                  :uk => {header: title_uk, content: desc_uk}},
                                                 alias: as,p_id: p_id, link: link)
    page_obj.save
  end
end