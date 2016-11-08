class Community::FilesController < ApplicationController
  include ControllerCaching

  before_action :set_file, except: [:create]

  # POST /community/communities
  # POST /community/communities.json
  def create

    params['file'].each{|f|
      doc = Community::File.new(community_file_params)
      doc.file = f
      community_file_params[:title].blank? ? doc.title = f.original_filename : doc.title = community_file_params[:title]
      doc.author = current_user.email unless current_user.nil?
      doc.save

      file = File.read('public/uploads/community/file/file/' + doc._id.to_s + '/' + doc.file.filename)

      doc.import JSON.parse(file)
    } unless params['file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  # PATCH/PUT /community/communities/1
  # PATCH/PUT /community/communities/1.json
  def update
    respond_to do |format|
      if @file.update(community_file_params)
        format.js
        format.json { head :no_content, status: :updated }
      else
        format.js
        format.json { render json: @file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /community/communities/1
  # DELETE /community/communities/1.json
  def destroy
    @file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content, status: :destroyed }
    end
  end

  private

  def set_file
    @file = Community::File.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def community_file_params
    params.require(:community_file).permit(:title)
  end
end
