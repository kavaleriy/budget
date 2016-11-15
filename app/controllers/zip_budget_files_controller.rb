class ZipBudgetFilesController < ApplicationController
  layout 'application_admin'

  include BudgetFileUpload

  before_action :generate_vz_file, only: [:create, :new]

  include BudgetFileTerra
  before_action :set_areas, only: [:new]

  def create
    def extract_file_data(entry)
      file_path = Rails.root.join('public', 'files', entry.name)
      entry.extract(file_path)

      month = (entry.name.match /(\d\d)M/)[1]
      table = read_table_from_file file_path
      table[:rows].each{|row| row.merge!('_month' => month) }

      table
    end

    def get_owner_town
      current_user.town_model
    end

    owner_town = get_owner_town

    def generate_budget_file entry, taxonomy, budget_file
      table = extract_file_data(entry)

      table[:rows].each{|row| row.merge!('_year' => params[:year]) } if params[:year]

      area_id = params[:area]
      town_id = table[:rows].last['ID_KEY']
      town = get_town area_id, town_id

      taxonomy.title = town
      taxonomy.locale = params['locale'] || 'uk'

      budget_file.title = "#{town} - #{DateTime.now.strftime('%d-%m-%Y')}"
      budget_file.name = entry.name
      budget_file.author = current_user.email unless current_user.nil?

      budget_file.cumulative_sum = true

      budget_file.import table

      budget_file.save!
    end

    Zip::File.open(zipbudgetfile_params[:path].tempfile) do |zip_file|
      @vz_file.title = zipbudgetfile_params[:path].original_filename
      @vz_file.path = zipbudgetfile_params[:path].original_filename

      zip_file.glob( "*M21*.dbf" ).each do |entry|
        next unless entry.name.match /^\d+M21(_\d+)?.dbf/

        taxonomy_name = entry.name.gsub(/\d\dM/i, 'XX')
        taxonomy = TaxonomyRot.find_or_create_by!(town: owner_town, name: taxonomy_name)

        budget_file = BudgetFileRotVz.find_or_create_by(taxonomy: taxonomy, path: "#{entry.name}.#{params[:year]}")

        generate_budget_file entry, taxonomy, budget_file

        @vz_file.rot_files << budget_file
      end

      zip_file.glob( "*22*.dbf" ).each do |entry|
        next unless entry.name.match /^\d+M22(_\d+)?.dbf/

        taxonomy_name = entry.name.gsub(/\d\dM/i, 'XX')
        taxonomy = TaxonomyRov.find_or_create_by!(town: owner_town, name: taxonomy_name)

        budget_file = BudgetFileRovVz.find_or_create_by(taxonomy: taxonomy, path: "#{entry.name}.#{params[:year]}")

        generate_budget_file entry, taxonomy, budget_file

        @vz_file.rov_files << budget_file
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
    params.require(params[:controller].singularize).permit(:data_type, :path)
  end

  def generate_vz_file
    @vz_file = ZipBudgetFile.new
  end

end
