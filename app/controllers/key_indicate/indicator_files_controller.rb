class KeyIndicate::IndicatorFilesController < ApplicationController
  include ControllerCaching

  before_action :authenticate_user!, only: [:new, :edit]
  load_and_authorize_resource

  before_action :set_town, only: [:new, :indicator_file_create, :indicator_file_destroy]
  before_action :get_towns, only: [:index, :get_vars]

  # GET /key_indicate/indicator_files
  # GET /key_indicate/indicator_files.json
  def index
    @indicators = get_data %w(Київ Львів Одеса), Time.now.year-1
  end

  def get_vars
    render :json => {'towns' => @towns, 'initial_towns' => @initial_towns}
  end

  # GET /key_indicate/indicator_files/1
  # GET /key_indicate/indicator_files/1.json
  def show
  end

  def reset_table
    @indicators = get_data params[:data], params[:year].to_i
    render :partial => '/key_indicate/indicator_files/indicators_table', :locals => {:indicators => @indicators, :towns => params[:data]}
  end

  def get_data data, year
    indicators = KeyIndicate::Dictionary.first.get_keys
    data.each{|title|
      town = ::Town.where(:title => title).first
      if !town.nil?
        get_indicators(town, year).each{|key, value|
          if indicators[key]
            if indicators[key]['type'] == 'to_i'
              amount = value['amount'].to_i
            else
              amount = value['amount'].to_f
            end
            indicators[key]['towns'] = {} if indicators[key]['towns'].nil?
            indicators[key]['towns'][title] = {} if indicators[key]['towns'][title].nil?
            indicators[key]['towns'][title]['amount'] = amount
            indicators[key]['max_amount'] = 0 if indicators[key]['max_amount'].nil?
            indicators[key]['max_amount'] = amount if amount > indicators[key]['max_amount']
            indicators[key]['towns'][title]['description'] = value['description']
          end
        }
      end
    }
    indicators
  end

  def get_indicators town, year
    indicators = {}
    town.key_indicate_indicator_files.each{|file|
      file.key_indicate_indicators.each{|indicator|
        if indicator['year'] == year
          key = indicator['key_indicator']
          indicators[key] = {}
          indicators[key]['amount'] = indicator['amount']
          indicators[key]['description'] = indicator['description']
        end
      }
    }
    indicators
  end

  # GET /key_indicate/indicator_files/new
  def new
  end

  # GET /key_indicate/indicator_files/1/edit
  def edit
  end

  def indicator_file_create
    @indicator_files = []

    params['indicate_file'].each do |f|
      doc = KeyIndicate::IndicatorFile.new
      doc.indicate_file = f
      params[:key_indicate_indicator_files][:title].blank? ? doc.title = f.original_filename : doc.title = params[:key_indicate_indicator_files][:title]
      doc.description = params[:key_indicate_indicator_files][:description]
      doc.town = @town
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/key_indicate/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      doc.import table
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  def indicator_file_update
    indicator_file = KeyIndicate::IndicatorFile.find(params[:indicator_file_id])
    respond_to do |format|
      if indicator_file.update(key_indicate_indicator_file_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @town.errors, status: :unprocessable_entity }
      end
    end
  end

  def indicator_file_destroy
    indicator_file = KeyIndicate::IndicatorFile.find(params[:indicator_file_id])
    indicator_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  def get_files
    @town = ::Town.find(params[:town])
    render :partial => '/key_indicate/indicator_files/indicator_files', :locals => {:town => @town, :files => @town.key_indicate_indicator_files }
  end

  private

  def get_towns
    @towns = use_cache do
      ::Town.all.reject{|t| t.key_indicate_indicator_files.length <= 0}
    end
    @initial_towns = @towns.reject{ |t| !%w(Київ Львів Одеса).include? t.title }.map{ |t| t.title }
    @towns.map!{ |t| [t.title, t.id.to_s] }
  end

  def set_town
    if current_user.town
      params[:town_select].nil? ? @town = ::Town.where(:title => current_user.town).first : @town = ::Town.find(params[:town_select])
    elsif current_user.has_role? :admin
      params[:town_select].nil? ? @town = ::Town.new(:title => "") : @town = ::Town.find(params[:town_select])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def key_indicate_indicator_file_params
    params.require(:key_indicate_indicator_file).permit(:year, :title, :indicator_file_id, :description)
  end

end
