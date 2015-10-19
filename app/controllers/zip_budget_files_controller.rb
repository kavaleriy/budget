class ZipBudgetFilesController < ApplicationController

  def new
    @vd_file = ZipBudgetFile.new

    @taxonomy_rots = TaxonomyRot.owned_by(current_user.town)
    @current_taxonomy_rot_id = @taxonomy_rots.last.id unless @taxonomy_rots.empty?

    @taxonomy_rovs = TaxonomyRov.owned_by(current_user.town)
    @current_taxonomy_rov_id = @taxonomy_rovs.last.id unless @taxonomy_rovs.empty?
  end

  def create
    # read zip

    rot_file = generate_rot_file
    rov_file = generate_rov_file

    @vd = Vd.create!(rot_file: rot_file, rov_file: rov_file)

    respond_to do |format|
      if @vd.save
        format.html { redirect_to @vd, notice: t('budget_files_controller.load_success') }
        format.json { render :show, status: :created, location: @vd }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def zipbudgetfile_params
    params.requirex(params[:controller].singularize).permit(:title, :taxonomy, :data_type, :path, :town)
  end



  protected

  def generate_vd_budget_file budget_file
    budget_file.author = current_user.email unless current_user.nil?

    budget_file.taxonomy.locale = params['locale'] || 'uk'

    file = upload_file budget_file_params[:path]
    file_name = file[:name]
    file_path = file[:path].to_s

    @budget_file.path = file_path

    @budget_file.title = budget_file_params[:title].empty? ? "#{file_name} - #{DateTime.now.strftime('%d-%m-%Y')}" : budget_file_params[:title]

    table = read_table_from_file file_path

    town =
        if UsersHelper.is_admin?(current_user)
          params[:town]
        else
          current_user.town
        end

    @budget_file.import town, table, params[:create_new_taxonomy] == 'true'

  end

  def generate_rot_file
    budget_file = BudgetFileRotVd.new
    if params[:taxonomy_rot_id]
      budget_file.taxonomy = Taxonomy.find params[:taxonomy_rot_id]
      town = budget_file.taxonomy.owner
    else
      town = find_town

      budget_file.taxonomy = TaxonomyRot.create!(:owner => town)
    end

    generate_vd_budget_file budget_file
  end

  def generate_rov_file
    budget_file = BudgetFileRovVd.new
    if params[:taxonomy_rov_id]
      budget_file.taxonomy = Taxonomy.find params[:taxonomy_rov_id]
      town = budget_file.taxonomy.owner
    else
      town = find_town

      budget_file.taxonomy = TaxonomyRov.create!(:owner => town)
    end

    generate_vd_budget_file budget_file
  end

  def find_town
    Town.find(params['town_select']) unless params['town_select'].blank?

    unless params['town'].blank?
      town = params['town'].split(',')
      if town.length > 1
        town = Town.where(:title => town[0].strip, :area_title => town[1].strip).first
      else
        town = Town.where(:title => town[0].strip).first
      end

      town
    end

  end

end
