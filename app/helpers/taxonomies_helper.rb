module TaxonomiesHelper
  def get_created_at(created_at)
    unless created_at.nil?
      created_at.strftime("%m/%d/%Y")
    else
      '-'
    end
  end

  def get_active_icon(active_fild)
    icon = "<i class='fa fa-square-o fa-lg'>"
    icon = "<i class='fa fa-check-square-o fa-lg'>" if active_fild
    icon.html_safe
  end
end