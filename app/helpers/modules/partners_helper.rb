module Modules::PartnersHelper
  def get_partner_id(partners, i, move)
    case move
      when 'left'
        partners[i-1].nil? ? partners.last : partners[i-1]
      when 'right'
        partners[i+1].nil? ? partners.first : partners[i+1]
    end
  end
end
