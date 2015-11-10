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
    t_title = @file_name.gsub(/ft(?<FTGZ>\d\d)\d\d\w\d/i, 'FT\k<FTGZ>XXXX')
    taxonomy = TaxonomyRot.find_or_create_by!(owner: @town_title, name: t_title)
    taxonomy.title = t_title
    taxonomy
  end

end
