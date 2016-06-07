class TemplateController < ApplicationController
  layout false

  PAGE_HEIGHT = '1135px'
  PAGE_WIDTH = '794px'

  def load
    @height = PAGE_HEIGHT
    @width = PAGE_WIDTH
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
