class StaticController < ApplicationController


  def get_dictionary
    @data = KeyIndicate::DictionaryKey.only(:key, :indicator, :unit)
    filename = "key_indicators_dictionary.xls"
    respond_to do |format|
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

end