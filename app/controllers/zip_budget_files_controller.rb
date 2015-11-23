class ZipBudgetFilesController < ApplicationController

  include BudgetFileUpload

  before_action :generate_vz_file, only: [:create, :new]

  def new
  end

  def create
    def extract_file_data(entry)
      file_path = Rails.root.join('public', 'files', entry.name)
      entry.extract(file_path)

      month = (entry.name.match /(\d\d)M/)[1]
      table = read_table_from_file file_path
      table[:rows].each{|row| row.merge!('_month' => month) }
      table
    end

    Zip::File.open(zipbudgetfile_params[:path].tempfile) do |zip_file|
      @vz_file.title = zipbudgetfile_params[:path].original_filename
      @vz_file.path = zipbudgetfile_params[:path].original_filename

      zip_file.glob( "*M21*.dbf" ).each do |entry|
        next unless entry.name.match /^\d+M21(_\d+)?.dbf/
        table = extract_file_data(entry)
        budget_file = create_rot_file(entry)
        @vz_file.rot_files << budget_file
        load_vz_budget_file budget_file, table
        budget_file.save!
      end

      zip_file.glob( "*22*.dbf" ).each do |entry|
        next unless entry.name.match /^\d+M22(_\d+)?.dbf/
        table = extract_file_data(entry)
        budget_file = create_rov_file(entry)
        @vz_file.rov_files << budget_file
        load_vz_budget_file budget_file, table
        budget_file.save!
      end

    end

    respond_to do |format|
      if @vz_file.save!
        format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_success') }
        format.json { render :show, status: :created, location: @vz_file }
      else
        format.html { render :new }
        format.json { render json: @vz_file.errors, status: :unprocessable_entity }
      end
    end

  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def zipbudgetfile_params
    params.require(params[:controller].singularize).permit(:title, :data_type, :path)
  end

  protected

  def load_vz_budget_file budget_file, table
    budget_file.author = current_user.email unless current_user.nil?

    budget_file.taxonomy.locale = params['locale'] || 'uk'

    budget_file.import table
  end

  def create_rot_file entry
    town_title = params['town_select'].blank? ? current_user.town : params['town_select']
    t_title = entry.name.gsub(/\d\dM/i, 'XX')
    taxonomy = TaxonomyRot.find_or_create_by!(owner: town_title, name: t_title)
    taxonomy.title = t_title

    budget_file = BudgetFileRotVz.find_or_create_by(taxonomy: taxonomy, path: entry.name)
    budget_file.title = "#{entry.name} | #{@vz_file.title} - #{DateTime.now.strftime('%d-%m-%Y')}"

    budget_file.cumulative_sum = true

    budget_file
  end

  def create_rov_file entry
    town_title = params['town_select'].blank? ? current_user.town : params['town_select']
    t_title = entry.name.gsub(/\d\dM/i, 'XX')
    taxonomy = TaxonomyRov.find_or_create_by!(owner: town_title, name: t_title)
    taxonomy.title = t_title

    budget_file = BudgetFileRovVz.find_or_create_by(taxonomy: taxonomy, path: entry.name)
    budget_file.title = "#{entry.name} | #{@vz_file.title} - #{DateTime.now.strftime('%d-%m-%Y')}"

    budget_file.cumulative_sum = true

    budget_file
  end

  private

  def generate_vz_file
    @vz_file = ZipBudgetFile.new
  end

end
