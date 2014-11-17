class VisifyController < ApplicationController
  before_action :set_budget_file

  after_action :allow_iframe

  layout 'visify'

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
    response.headers.except! 'X-Frame-Options'
  end
end