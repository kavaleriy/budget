module PublicHelper
  def show_town_blazon(town)
    path = File.exist?(town.img.thumb.path) ? town.img.thumb.url : 'new_design/blason.svg'
    image_tag(path, class: 'img-responsive')
  end
end
