class EventsController < ApplicationController
  include ApplicationHelper
  layout false

  before_action :set_calendar
  before_action :set_event, only: [:show, :edit, :update, :destroy, :update_files_description, :delete_attachments, :download_attachments]
  before_action :set_attachments, only: [:show]
  before_action :set_attachment, only: [:update_files_description, :delete_attachments, :download_attachments]
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale]
  end

  load_and_authorize_resource :calendar
  load_and_authorize_resource :event, :through => :calendar

  # GET /events
  # GET /events.json
  def index
    @events = @calendar.events.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      # format.html { render( partial: 'show') if request.xhr? }
      format.js
    end
  end

  # GET /events/indicator_file
  def new
    all_day = params[:all_day] == "true"
    @event = @calendar.events.new(
        :starts_at => params[:starts_at],
        :ends_at => params[:ends_at],
        :all_day => all_day,
        :text_color => '#ffffff',
        :color => '#8cc0f1'
    )

    respond_to do |format|
      format.js
    end
  end

  # GET /events/1/edit
  def edit
    respond_to do |format|
      format.js
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = @calendar.events.new(event_params)
    respond_to do |format|
      if @event.save
        format.json { render json: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  def download_attachments
    file_name = @attachment.name
    file_path = get_attachment_path file_name, @event.id
    if File.exist?(file_path)
      send_file(
          "#{file_path}",
          :x_sendfile=>true
      )
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update

    respond_to do |format|
      if @event.update(event_params)
        format.json { render json: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST/PUT /events/1
  # POST/PUT /events/1.json
  def upload_files
    params[:files].each do |attachment|
      upload_file attachment, @event.id
      file = @event.event_attachments.new(
          :name=>attachment.original_filename,
      )
      respond_to do |format|
        if file.save
          format.html {
            render :json => file
          }
        else
          format.json { render json: @budget_file.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  def update_files_description
    respond_to do |format|
      @attachment.description = params[:description]
      if @event.save
        format.json { render json: @attachment }
      else
         format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end


  def delete_attachments
    file_path = get_attachment_path @attachment.name, @event.id
    respond_to do |format|
      if File.exist?(file_path)
        if File.delete(file_path)
          @attachment.destroy
          format.json { head "OK" }
        end
      else
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.



  def get_attachment_path filename, event_id
    Rails.root.join('public', 'files', 'attachments', event_id, filename)
  end



  def upload_file (attachment, event_id)
    file_name = attachment.original_filename
    Dir.mkdir('public/files/attachments/' + event_id) unless File.exists?('public/files/attachments/' + event_id)
    file_path = get_attachment_path file_name, @event.id
    File.open(file_path, 'wb') do |file|
      file.write(attachment.read)
    end
  end

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def set_event
    @event = @calendar.events.find(params[:id])
  end

  def set_attachment
    @attachment = @event.event_attachments.find(params[:attachment_id])
  end
  def set_attachments
    @attachments = @event.event_attachments
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:holder, :title, :icon, :description, :starts_at, :ends_at, :all_day, :text_color, :color)
  end

end
