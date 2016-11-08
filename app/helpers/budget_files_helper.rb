module BudgetFilesHelper
  def icons(value)
    # function receives type of budget_file from DB ('plan', 'fact' or empty) and return <span> with class-atributes and value
    # classes explain in css in index.html
    value.to_s.size != 0 ? "<span class='#{value.to_s}-icon'>#{value.to_s[0].upcase}</span>" : "<span class='pf-icon'></span>"
  end
end
