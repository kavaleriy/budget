namespace :documentation_category do

  desc "recalculate position"
    task :recalculate_position => :environment do
    update_position(Documentation::Category.tree_root)
  end

  private
    def update_position(categories)
      position = 0
      categories.each do |category|
        puts "#{position} - #{category.title}"
        category.update(:position => position)
        position += 1

        update_position(Documentation::Category.tree(category.id))
      end

    end

end
