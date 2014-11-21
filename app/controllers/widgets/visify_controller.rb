class Widgets::VisifyController < Widgets::WidgetsController
  before_action :set_budget_file

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
    @budget_file = BudgetFile.find(params[:file_id])
  end

end
