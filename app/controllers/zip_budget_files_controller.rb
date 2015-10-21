class ZipBudgetFilesController < ApplicationController

  include BudgetFileUpload

  before_action :generate_vd_file, only: [:create, :new]

  def new
  end

  def create
    file_path = nil

    Zip::File.open(zipbudgetfile_params[:path].tempfile) do |zip_file|
      # Find specific entry
      entry = zip_file.glob('*ZVED.dbf').first

      next if entry.nil?

      @vd_file.title = entry.name

      file_path = Rails.root.join('public', 'files', entry.name)
      entry.extract(file_path)

      @vd_file.path = file_path

      @vd_file.rot_file = create_rot_file
      @vd_file.rov_file = create_rov_file

      table = read_table_from_file file_path

      load_vd_budget_file @vd_file.rot_file, table
      load_vd_budget_file @vd_file.rov_file, table
    end

    respond_to do |format|
      if @vd_file.path && @vd_file.save! && @vd_file.rot_file.save! && @vd_file.rov_file.save!
        format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_success') }
        format.json { render :show, status: :created, location: @vd_file }
      else
        format.html { render :new }
        format.json { render json: @vd_file.errors, status: :unprocessable_entity }
      end
    end

  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def zipbudgetfile_params
    params.require(params[:controller].singularize).permit(:title, :data_type, :path)
  end


  protected

  def load_vd_budget_file budget_file, table
    budget_file.data_type = :fact

    budget_file.title = zipbudgetfile_params[:title].empty? ? "#{@vd_file.title} - #{DateTime.now.strftime('%d-%m-%Y')}" : zipbudgetfile_params[:title]
    budget_file.author = current_user.email unless current_user.nil?

    budget_file.taxonomy.locale = params['locale'] || 'uk'

    budget_file.import table
  end

  def create_rot_file
    budget_file = BudgetFileRotVd.new

    budget_file.taxonomy =
        if params[:budget_file_taxonomy_rot].blank?
          town_title = params['town_select'].blank? ? current_user.town : params['town_select']
          TaxonomyRot.create!(:owner => town_title)
        else
          Taxonomy.find params[:budget_file_taxonomy_rot]
        end

    budget_file
  end

  def create_rov_file
    budget_file = BudgetFileRovVd.new

    budget_file.taxonomy =
        if params[:budget_file_taxonomy_rov].blank?
          town_title = params['town_select'].blank? ? current_user.town : params['town_select']
          TaxonomyRov.create!(:owner => town_title)
        else
          Taxonomy.find params[:budget_file_taxonomy_rov]
        end

    budget_file
  end

  private

  def generate_vd_file
    @vd_file = ZipBudgetFile.new

    @taxonomy_rots = TaxonomyRot.owned_by(current_user.town)
    @current_taxonomy_rot_id = params[:budget_file_taxonomy_rot] || @taxonomy_rots.last.id unless @taxonomy_rots.empty?

    @taxonomy_rovs = TaxonomyRov.owned_by(current_user.town)
    @current_taxonomy_rov_id = params[:budget_file_taxonomy_rov] ||@taxonomy_rovs.last.id unless @taxonomy_rovs.empty?
  end



end
