module TaxonomiesHelper
  def get_created_at(created_at)
    unless created_at.nil?
      created_at.strftime("%m/%d/%Y")
    else
      '-'
    end
  end
end