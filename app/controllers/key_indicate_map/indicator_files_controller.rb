class KeyIndicateMap::IndicatorFilesController < ApplicationController
  before_action :set_key_indicate_map_indicator_file, only: [:show, :edit, :update, :update_town, :update_key, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /key_indicate_map/indicator_files
  # GET /key_indicate_map/indicator_files.json
  def index
    @key_indicate_map_indicator_files = KeyIndicateMap::IndicatorFile.all
  end

  # GET /key_indicate_map/indicator_files/1
  # GET /key_indicate_map/indicator_files/1.json
  def show
  end

  # GET /key_indicate_map/indicator_files/new
  def new
    @key_indicate_map_indicator_file = KeyIndicateMap::IndicatorFile.new
  end

  # GET /key_indicate_map/indicator_files/1/edit
  def edit
    @indicators = {}
    @towns = {}
    year = @key_indicate_map_indicator_file['year'].to_s

    @key_indicate_map_indicator_file.key_indicate_map_indicators.each{|indicator|
      if indicator.key_indicate_map_indicator_key
        name = indicator.key_indicate_map_indicator_key['name']
        @indicators[name] = {} if @indicators[name].nil?
        @indicators[name]['indicator_id'] = indicator.id
        @indicators[name]['description'] = indicator.key_indicate_map_indicator_key['history'][year]['description'] if indicator.key_indicate_map_indicator_key['history'][year]
        @indicators[name]['total'] = indicator.key_indicate_map_indicator_key['history'][year]['total'] if indicator.key_indicate_map_indicator_key['history'][year]
      else
        name = indicator['indicator_errors']['1']['key']
        @indicators[name] = {} if @indicators[name].nil?
        @indicators[name]['description'] = indicator['indicator_errors']['1']['description']
        @indicators[name]['total'] = indicator['indicator_errors']['1']['total']
        @indicators[name]['error'] = true
      end
      if indicator.town
        @towns[indicator.town['title']] = {} if @towns[indicator.town['title']].nil?
        @towns[indicator.town['title']]['values'] = {} if @towns[indicator.town['title']]['values'].nil?
        @towns[indicator.town['title']]['values'][name] = indicator.value
      else
        @towns[indicator['indicator_errors']['2']] = {} if @towns[indicator['indicator_errors']['2']].nil?
        @towns[indicator['indicator_errors']['2']]['values'] = {} if @towns[indicator['indicator_errors']['2']]['values'].nil?
        @towns[indicator['indicator_errors']['2']]['values'][name] = indicator.value
        @towns[indicator['indicator_errors']['2']]['error'] = true
      end
    }
  end

  # POST /key_indicate_map/indicator_files
  # POST /key_indicate_map/indicator_files.json
  def create
    @indicator_files = []

    params['indicate_file'].each do |f|
      doc = KeyIndicateMap::IndicatorFile.new
      doc.indicate_file = f
      params[:key_indicate_map_indicator_file][:title].blank? ? doc.title = f.original_filename : doc.title = params[:key_indicate_map_indicator_file][:title]
      doc.description = params[:key_indicate_map_indicator_file][:description]
      doc.year = params[:year]
      doc.author = current_user.email
      if !doc.save
        respond_to do |format|
          format.js {render :js=> 'alert("' + doc.errors.messages[:year][0] + '");' }
          format.json { head :no_content, status: :unprocessable_entity }
        end
        return
      end
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/key_indicate_map/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      @errors = doc.import table, doc.year
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  # PATCH/PUT /key_indicate_map/indicator_files/1
  # PATCH/PUT /key_indicate_map/indicator_files/1.json
  def update

    if key_indicate_map_indicator_file_params[:year]
      year = @key_indicate_map_indicator_file.year.to_s
      KeyIndicateMap::IndicatorKey.each{|key|
        if key['history'] && key['history'][year]
          attrs = key['history'].reject{|key, value| key == year }
          attrs[key_indicate_map_indicator_file_params[:year]] = key['history'][year]
          key.update_attributes({:history => attrs})
        end
      }
    end

    respond_to do |format|
      if @key_indicate_map_indicator_file.update(key_indicate_map_indicator_file_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.html { render :edit }
        format.json { render json: @key_indicate_map_indicator_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_town
    @key_indicate_map_indicator_file.key_indicate_map_indicators.select{|i| i['indicator_errors'] && i['indicator_errors']['2'] == params[:old_town]}.each{|indicator|
      indicator['indicator_errors'].reject!{|key, value| key == '2'}
      indicator.town_id = key_indicate_map_indicator_file_params[:town]
      indicator.save
    }

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :updated }
    end
  end

  def update_key
    old_key = params[:old_key].split("indicator_key=")[1].gsub("+"," ")
    @key_indicate_map_indicator_file.key_indicate_map_indicators.select{|i| i['indicator_errors'] && i['indicator_errors']['1'] && i['indicator_errors']['1']['key'] == old_key}.each{|indicator|
      key = KeyIndicateMap::IndicatorKey.find(key_indicate_map_indicator_file_params[:indicator_key])
      key['history'] = {} if key['history'].nil?
      year = @key_indicate_map_indicator_file.year.to_s
      key['history'][year] = {}
      key['history'][year]['description'] = indicator['indicator_errors']['1']['description'] unless indicator['indicator_errors']['1']['description'].nil?
      key['history'][year]['total'] = indicator['indicator_errors']['1']['total'] unless indicator['indicator_errors']['1']['total'].nil?
      key.save
      indicator.key_indicate_map_indicator_key = key
      indicator['indicator_errors'].reject!{|key, value| key == '1'}
      indicator.save
    }

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :updated }
    end
  end

  # DELETE /key_indicate_map/indicator_files/1
  # DELETE /key_indicate_map/indicator_files/1.json
  def destroy
    year = @key_indicate_map_indicator_file['year'].to_s
    KeyIndicateMap::IndicatorKey.each{|key|
      if !key['history'].nil? && !key['history'][year].nil?
        attrs = {:history => key['history'].reject{|key, value| key == year }}
        key.update_attributes(attrs)
      end
    }
    @key_indicate_map_indicator_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :destroy }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_map_indicator_file
      @key_indicate_map_indicator_file = KeyIndicateMap::IndicatorFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_map_indicator_file_params
      params.require(:key_indicate_map_indicator_file).permit(:title, :description, :year, :town, :old_town, :indicator_key, :old_key)
    end
end
