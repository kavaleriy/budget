class BudgetFileRovVdsController < BudgetFileRovsController

  protected

  def get_file_name_for uploaded_io
    "#{uploaded_io.original_filename}.dbf"
  end

  def generate_budget_file
    if @taxonomy
      @budget_file = BudgetFileRovVd.find_or_create_by(taxonomy: @taxonomy, name: @file_name)
    else
      @budget_file = BudgetFileRovVd.new
    end
    @budget_file.data_type = :fact
  end

  def get_taxonomies owner
  end

  def create_taxonomy
    t_title = @file_name.gsub(/vd(?<VDGZ>\d\d)\d\d\w\d/i, 'VD\k<VDGZ>XXXX')
    taxonomy = TaxonomyRov.find_or_create_by!(owner: @town_title, name: t_title)
    taxonomy.title = t_title
    taxonomy
  end

end
