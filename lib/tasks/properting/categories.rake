namespace :categories do
  desc "copy categories"
  task copy_root_categories: :environment do
    categories = Repairing::Category.tree_root

    categories.each do |category|
      new_category = Properting::Category.create!(
        category_id: "#",
        locale: "uk",
        title: category.title,
        position: category.position,
        img: Rails.root.join(category.img.path).open
      )

      p new_category
    end
  end

end
