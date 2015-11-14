class BudgetFileRotFtsController < BudgetFileRotsController

  protected

  def get_file_name_for uploaded_io
    "#{uploaded_io.original_filename}.dbf"
  end

  def generate_budget_file
    if @taxonomy
      @budget_file = BudgetFileRotFt.find_or_create_by(taxonomy: @taxonomy, name: @file_name)
    else
      @budget_file = BudgetFileRotFt.new
    end
    @budget_file.data_type = :fact
  end

  def get_taxonomies owner
  end

  def create_taxonomy
    t_title = @file_name.gsub(/ft(?<BUDGET>\d\d)\d\w\w\d\.(?<TERRA>\d\d\d)/i, 'FT\k<BUDGET>xxxx.\k<TERRA>')
    taxonomy = TaxonomyRot.find_or_create_by!(owner: @town_title, name: t_title, cumulative_sum: true)
    taxonomy.title = t_title
    taxonomy
  end

end
