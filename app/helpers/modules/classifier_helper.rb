module Modules::ClassifierHelper
  def youcontrol_edrpou_link(edrpou)
    if edrpou.length == 8
      link_to edrpou,
              "https://youcontrol.com.ua/catalog/company_details/#{edrpou}",
              target: '_blank',
              title: 'Більше інформації про контрагента можна отримати в Youcontrol'
    else
      edrpou
    end
  end

end
