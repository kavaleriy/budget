class TemplateController < ApplicationController
  layout false

  def load
    partial_name = params[:partial_name]
    render partial_name
  end

  def content
  end

  def content_page
  end

  def title
  end

  def last_page
  end
end
