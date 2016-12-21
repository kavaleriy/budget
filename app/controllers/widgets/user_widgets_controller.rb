class Widgets::UserWidgetsController < Widgets::WidgetsController
  # layout false
  def visualisation_list

    @presenter = ExportBudget::FormPresenter.new(params[:town_id],params[:locale])

    respond_to do |format|
      # format.html
      format.js
    end
  end

end
