class EventAttachmentsController < ApplicationController
  before_action :set_calendar, only: [:update, :create]
  before_action :set_event, only: [:update, :create]
  before_action :set_event_attachment, only: [:update]




  # POST /documentation/documents
  # POST /documentation/documents.json
  def create
    #binding.pry
    @event_attachment = @event.event_attachments.new(event_attachment_params)
    @event_attachment.name = '1'
    #binding.pry
    respond_to do |format|
      if @event_attachment.save
        format.js {
        }
        format.json { head :no_content, status: :created }
      else
        format.js
        format.json { render json: @event_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/documents/1
  # PATCH/PUT /documentation/documents/1.json
  def update
    respond_to do |format|
      if @event_attachment.update(event_attachment_params)
        format.js
        format.json { render :show, status: :ok, location: @event_attachment }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @event_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/documents/1
  # DELETE /documentation/documents/1.json
  def destroy
    @documentation_document.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_calendar
      @calendar = Calendar.find(params[:calendar_id])
    end

    def set_event
      @event = @calendar.events.find(params[:event_id])
    end

    def set_event_attachment
      @event_attachment = @event.event_attachments.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def event_attachment_params
      params.require(:event_attachment).permit(:name, :description, :doc_file)
    end
end
