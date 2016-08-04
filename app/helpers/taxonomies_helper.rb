module TaxonomiesHelper
  def get_created_at(created_at)
    unless created_at.nil?
      created_at.strftime("%m/%d/%Y")
    else
      '-'
    end
  end

  def get_active_icon(active_fild)
    if active_fild
      icon = "<i class='fa fa-check-square-o fa-lg'>"
    else
      icon = "<i class='fa fa-square-o fa-lg'>"
    end
    # if active_fild.nil? || !active_fild
    #   "<i class='fa fa-square-o fa-lg'>"
    # else
    #   "<i class='fa fa-check-square-o fa-lg'>"
    # end
    icon.html_safe
  end
end