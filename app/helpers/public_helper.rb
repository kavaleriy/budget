module PublicHelper
  def show_town_blazon(town)
    path = File.exist?(town.img.thumb.path.to_s) ? town.img.thumb.url : 'new_design/blason.svg'
    image_tag(path, class: 'img-responsive')
  end

  def eidos_logo
    #TODO: to else put english logo version path
    logo_path = I18n.locale == :uk ? 'new_design/eidos-logo.png' : 'new_design/eidos-logo.png'
    image_tag(logo_path, class: 'img-responsive')
  end
end