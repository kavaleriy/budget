class TemplateController < ApplicationController
  layout false

  def load
    partial_name = params[:partial_name]
    render partial_name
  end
end
