include Rails.application.routes.url_helpers
namespace :create_slider do

  task empty_slider: :environment do
    Modules::Slider.all.each { |slider| slider.destroy }
  end

  task fill_slider: :empty_slider do
    save_slider("Порівняння бюджетів",'sl01.jpg')
    save_slider("Співпраця з органам місцевого самоврядування","sl02.jpg")
    save_slider("Співпраця з громадськими організаціями","sl03.jpg")
    save_slider("Порівняння ключових показників","sl04.jpg",key_indicate_map_indicators_path)
    save_slider("Бюджетний календар","sl05.jpg")
  end


  def save_slider(text,img_path,link = '#')
    sl1 = Modules::Slider.new(text: text,img: File.open(get_file_path(img_path)),link: link)
    sl1.set_sl_order
    sl1.save
  end
  def get_file_path(name)
    Rails.root.join('app', 'assets', 'images','slider', name)
  end
end