class Hackatton::DaniMistController < ApplicationController
  layout false
  def load_data
    @dani_mist = ExternalApi.dani_mist_data('https://data.danimist.org.ua/dataset/9abc5a08-3e46-4be8-94d5-49e1a3352988/resource/d1770d50-db3a-4416-b221-5d319c2b9159/download/routesbusdnipro.csv')
  end
end
