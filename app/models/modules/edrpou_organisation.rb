class Modules::EdrpouOrganisation
  require 'external_api'
  include Mongoid::Document
  field :edrpou, type: String

  validates_presence_of :edrpou

  def title
    edr_data_arr = ExternalApi.edr_data(self.edrpou)
    # @edr_data = edr_data_arr.first['officialName'] unless edr_data_arr.nil?

    unless edr_data_arr.blank?
      @edr_data = edr_data_arr.first['officialName']
    else
      'Дані відсутні'
    end
  end
end
