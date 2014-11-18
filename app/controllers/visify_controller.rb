class VisifyController < ApplicationController
  before_action :set_budget_file

  after_action :allow_iframe

  layout 'visify'

  def get_sunburst_data
    render json: @budget_file.get_sunburst_tree
  end

  def get_bubbletree_data
    render json: @budget_file.get_bubble_tree
  end

  def sunburst
  end

  def sunburst_seq
  end

  def bubbletree
  end

  def circles
  end

  def treemap
  end

  def collapsible
  end

private
  def set_budget_file
    @budget_file = BudgetFile.find(params[:id])
  end

  def allow_iframe
    response.headers['x-frame-options'] = 'ALLOWALL'
    #response.headers['X-Frame-Options'] = 'ALLOW-FROM http://dhrp.org.ua'

  end
end