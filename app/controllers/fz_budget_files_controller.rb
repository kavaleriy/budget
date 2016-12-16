class FzBudgetFilesController < ApplicationController

  include BudgetFileUpload

  layout 'application_admin'

  include BudgetFileUpload

  def new
    def get_taxonomies_list model
      taxs = model.by_town(current_user.town_model)
      tax_id = taxs.last.id unless taxs.blank?
      [taxs, tax_id]
    end

    @fz_file = FzBudgetFile.new

    @taxonomies_rot, @current_taxonomy_rot_id = get_taxonomies_list(TaxonomyRot)
    @taxonomies_rov, @current_taxonomy_rov_id = get_taxonomies_list(TaxonomyRov)
  end



  def create
    taxonomy_rot = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rot]) rescue nil
    taxonomy_rov = Taxonomy.find_by(:id => params[:budget_file_taxonomy_rov]) rescue nil

    # raise 'Не вказано код місцевого бюджету. Необхідно налаштувати параметри візуалізації' if taxonomy_rot.kmb.blank? || taxonomy_rov.kmb.blank?

    fzbudgetfile_params[:path].each do |uploaded|
      file = upload_file uploaded, uploaded.original_filename

      upload_rzt = ->() do
        path = file[:path].to_s
        name = file[:name].gsub(/rzt(?<NUM>\d\d\d\d\d).(?<TERRA>\d\d\d).*/i, 'RZT\k<NUM>.\k<TERRA>')

        fz_name = file[:name].gsub(/rzt\d\d\d\d\d.(?<TERRA>\d\d\d).*/i, 'RZD.\k<TERRA>')
        fz_file = FzBudgetFile.find_or_create_by(title: fz_name)

        budget_file = BudgetFileRotRzt.find_or_create_by(name: name, taxonomy: taxonomy_rot, data_type: :plan)
        budget_file.title = name + ' - Доходи'
        budget_file.path = path
        budget_file.make_empty
        budget_file.author = current_user.email

        rows = read_table_from_file(path)[:rows]
        budget_file.import rows

        fz_file.rot_file << budget_file
        fz_file.save!
      end

      upload_rzv = ->() do
        path = file[:path].to_s
        name = file[:name].gsub(/rzv(?<NUM>\d\d\d\d\d).(?<TERRA>\d\d\d).*/i, 'RZV\k<NUM>.\k<TERRA>')

        fz_name = file[:name].gsub(/rzv\d\d\d\d\d.(?<TERRA>\d\d\d).*/i, 'RZD.\k<TERRA>')
        fz_file = FzBudgetFile.find_or_create_by(title: fz_name)

        budget_file = BudgetFileRovRzv.find_or_create_by(name: name, taxonomy: taxonomy_rov, data_type: :plan)
        budget_file.title = name + ' - Видатки'
        budget_file.path = path
        budget_file.make_empty
        budget_file.author = current_user.email

        rows = read_table_from_file(path)[:rows]
        budget_file.import rows

        fz_file.rov_file << budget_file
        fz_file.save!
      end

      upload_fz = ->() do
        fz_file = FzBudgetFile.new
        fz_file.title = file[:name]
        fz_file.path = file[:path].to_s

        def remove_old_fz user_name, file_name
          BudgetFile.where(:author => user_name, :name => file_name).destroy_all
        end

        remove_old_fz(current_user.email, file[:name])

        calc_annual_rows = ->(rows) do
          rows.each do |row|
            row['m0'] = (1..12).map { |i| row["m#{i}"].to_f }.sum
          end
        end

        rows = calc_annual_rows.call(read_table_from_file(fz_file.path)[:rows])

        rot_file = BudgetFileRotFz.new(title: fz_file.title + ' - Доходи', taxonomy: taxonomy_rot, path: fz_file.path) if taxonomy_rot
        rov_file = BudgetFileRovFz.new(title: fz_file.title + ' - Видатки', taxonomy: taxonomy_rov, path: fz_file.path) if taxonomy_rov

        [rot_file, rov_file].compact.each do |budget_file|
          budget_file.data_type = :plan
          budget_file.author = current_user.email
          budget_file.name = file[:name]
          budget_file.import rows
        end

        fz_file.rot_file << rot_file
        fz_file.rov_file << rov_file

        fz_file.save!
      end


      if file[:name] =~ /^rzt/i # rot oda
        upload_rzt.call
      elsif file[:name] =~ /^rzv/i # rov oda
        upload_rzv.call
      elsif file[:name] =~ /^fz/i # rot/v city
        upload_fz.call
      end
    end

    respond_to do |format|
      format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_success') }
      format.json { render :show, status: :created, location: @vz_file }
    end

  rescue => e
    message = "Не вдалося завантажити файл : #{e}"
    respond_to do |format|
      format.html { redirect_to :back, alert:  message }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def fzbudgetfile_params
    params.require(params[:controller].singularize).permit(:title, :data_type, :taxonomy_rot, :taxonomy_rov, :path => [])
  end

end
