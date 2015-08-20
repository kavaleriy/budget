class Public::DocumentsController < ApplicationController
  layout 'application_public'

  include ControllerCaching

  def index
    @documentation_documents = Documentation::Document.all
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

    @towns = use_cache controller_path do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

    @towns = @towns.select{ |t| params["town_select"].split(',').include? t.id.to_s } unless params["town_select"].blank?

    @town_select = unless params[:town_select].blank?
                     town_select = Town.find(params[:town_select])
                     { :id => town_select[:id], :title => town_select[:title] }
                   end || { }

    @branch_select = params[:branch_select] unless params[:branch_select].blank?
  end
end
