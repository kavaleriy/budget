class FzBudgetFilesController < ApplicationController

  include BudgetFileUpload

  layout 'application_admin'

  include BudgetFileUpload

  def new
    def get_taxonomies_list model
      taxs = model.owned_by(current_user.town)
      tax_id = taxs.last.id unless taxs.blank?
      [taxs, tax_id]
    end

    @fz_file = FzBudgetFile.new

    @taxonomies_rot, @current_taxonomy_rot_id = get_taxonomies_list(TaxonomyRot)
    @taxonomies_rov, @current_taxonomy_rov_id = get_taxonomies_list(TaxonomyRov)
  end

  def create
    taxonomy_rot = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rot])
    taxonomy_rov = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rov])

    fzbudgetfile_params[:path].each do |uploaded|
      file = upload_file uploaded, uploaded.original_filename

      fz_file = FzBudgetFile.new
      fz_file.title = file[:name]
      fz_file.path = file[:path].to_s

      table = read_table_from_file fz_file.path

      fz_file.rot_file = BudgetFileRotFz.new(title: 'Доходи - ', taxonomy: taxonomy_rot) if taxonomy_rot
      fz_file.rov_file = BudgetFileRovFz.new(title: 'Видатки - ', taxonomy: taxonomy_rov) if taxonomy_rov

      [fz_file.rot_file, fz_file.rov_file].compact.each do |budget_file|
        budget_file.title += fz_file.title
        budget_file.data_type = :plan
        budget_file.import table
      end

      fz_file.save!
    end

    respond_to do |format|
      format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_success') }
      format.json { render :show, status: :created, location: @vz_file }
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def fzbudgetfile_params
    params.require(params[:controller].singularize).permit(:title, :data_type, :taxonomy_rot, :taxonomy_rov, :path => [])
  end

end
