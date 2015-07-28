class StaticController < ApplicationController


  def get_dictionary
    @data = KeyIndicate::DictionaryKey.only(:key, :indicator, :unit)
    respond_to do |format|
      format.csv { send_data @data.to_csv }
    end
  end

end