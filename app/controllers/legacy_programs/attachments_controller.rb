class LegacyPrograms::AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:update, :destroy]
  before_action :set_target_program, only: [:destroy]

  # POST /programs/expences_files
  # POST /programs/expences_files.json
  def create

    @attachments = []
    @programs_target_program = Programs::TargetProgram.where(:id => params[:programs_attachment][:program_id]).first

    params['attachment'].each do |f|
      doc = Programs::Attachment.new
      doc.attachment = f
      doc.programs_target_program = @programs_target_program
      params[:programs_attachment][:title].present? ? doc.title = params[:programs_attachment][:title] : doc.title = f.original_filename
      doc.author = current_user.email
      doc.save
      @attachments << doc

    end unless params['attachment'].nil?

    respond_to do |format|
      format.js {}
    end


  end

  # PATCH/PUT /programs/expences_files/1
  # PATCH/PUT /programs/expences_files/1.json
  def update
    respond_to do |format|
      if @attachment.update(programs_attachment_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/expences_files/1
  # DELETE /programs/expences_files/1.json
  def destroy
    @attachment.destroy
    respond_to do |format|
      format.js {}
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attachment
      @attachment = Programs::Attachment.find(params[:id])
    end

    def set_target_program
      @programs_target_program = @attachment.programs_target_program
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_attachment_params
      params.require(:programs_attachment).permit(:program_id, :title)
    end
end
