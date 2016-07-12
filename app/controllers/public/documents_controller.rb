class Public::DocumentsController < ApplicationController
  include ControllerCaching

  def index
    # @documentation_documents = Documentation::Document.all
    if params[:town_id].nil?
      @documentation_documents = Documentation::Document.all
    else
      @documentation_documents = Documentation::Document.get_documents_by_town(params[:town_id])
    end
    @documentation_documents = @documentation_documents.select{ |doc| params["town_select"].split(',').include? doc.town_id.to_s } unless params["town_select"].blank?
    @documentation_documents = @documentation_documents.select{ |doc| doc.branch_id && (params["branch_select"].include? doc.branch_id.to_s) } unless params["branch_select"].blank?
    @documentation_documents = @documentation_documents.select{ |doc| doc.yearFrom && ((doc.yearFrom <= params["year"].to_i && doc.yearTo && doc.yearTo >= params["year"].to_i) || doc.yearFrom == params["year"].to_i) } unless params["year"].blank?
    @documentation_documents = @documentation_documents.select{ |doc| doc.title.match(Regexp.new(".*"+params["q"]+".*")) } unless params["q"].blank?
    if current_user
      documentation_documents = @documentation_documents.select{ |doc| !doc.locked || doc.owner_id == current_user.id }
    else
      documentation_documents = @documentation_documents.select{ |doc| !doc.locked }
    end

    @documentation_documents = @documentation_documents & documentation_documents

    if params["sort"].blank? || params["sort"] == "type"
      @documentation_documents.sort_by!{|doc| doc.branch ? doc.branch[:title] : ""  }
    elsif params["sort"] == "name"
      @documentation_documents.sort_by!{|doc| doc.title ? doc.title : ""  }
    end

    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

    @towns = @towns.select{ |t| params["town_select"].split(',').include? t.id.to_s } unless params["town_select"].blank?

    @town_select = unless params[:town_select].blank?
                     town_select = Town.find(params[:town_select])
                     { :id => town_select[:id], :title => town_select[:title] }
                   end || { }

    @branch_select = params[:branch_select] unless params[:branch_select].blank?

    js_view = params[:town_id].nil? ? 'index' : 'modules'
    respond_to do |format|
      format.html
      format.js{ render js_view }
    end
  end

  def find_by_title_part
    @documents = Documentation::Document.get_documents_by_town(params[:town_id]).get_by_part_of_title(params[:query]).unlocked
    respond_to do |format|
      format.js {render 'public/documents/new_design/search_result'}
    end
  end
end
