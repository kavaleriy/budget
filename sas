
[1mFrom:[0m /home/alex/work/openBudget/budget/app/controllers/public/towns_controller.rb @ line 35 Public::TownsController#show:

    12: [32mdef[0m [1;34mshow[0m
    13:   @export_budget = [1;34;4mExportBudget[0m.new
    14: 
    15:   @export_budgets = [1;34;4mExportBudget[0m.all
    16: 
    17:   @calendars = [1;34;4mCalendar[0m.where([33m:town[0m => @town)
    18: 
    19:   @town_export_budgets = [1;34;4mExportBudget[0m.where([33m:town[0m => @town.id)
    20: 
    21:   @town_links = {}
    22:   [32mif[0m @town.blank?
    23:     @town_br_links = [1;34;4mDocumentation[0m::[1;34;4mLink[0m.all.where([33m:town[0m => [1;36mnil[0m)
    24:   [32melse[0m
    25:     @town_br_links = [1;34;4mDocumentation[0m::[1;34;4mLink[0m.all.where([33m:town[0m => @town)
    26:   [32mend[0m
    27: 
    28:   [1;34;4mDocumentation[0m::[1;34;4mLinkCategory[0m.all.each{|br|
    29:     @town_links[br.id.to_s] = {}
    30:     @town_links[br.id.to_s][[31m[1;31m'[0m[31mtitle[1;31m'[0m[31m[0m] = br.title
    31:     @town_links[br.id.to_s][[31m[1;31m'[0m[31mlinks[1;31m'[0m[31m[0m] = @town_br_links.select{|t| t.link_category == br}
    32: 
    33:   }
    34:   @town_items = get_town_items(@town)
 => 35:   binding.pry
    36: [32mend[0m

