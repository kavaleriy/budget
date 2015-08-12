class Public::DocumentsController < ApplicationController
  layout 'application_public'

  include ControllerCaching

  def index
    @documentation_documents = Documentation::Document
    @documentation_documents = @documentation_documents.where(:town.in => params["town_select"].split(',')) unless params["town_select"].blank?
    @documentation_documents = @documentation_documents.where(:branch.in => params["branch_select"]) unless params["branch_select"].blank?
    @documentation_documents = @documentation_documents.where(:yearFrom.lte => params["year"].to_i, :yearTo.gte => params["year"].to_i) unless params["year"].blank?
    @documentation_documents = @documentation_documents.where(:title => Regexp.new(".*"+params["q"]+".*")) unless params["q"].blank?
    if current_user
      @documentation_documents = @documentation_documents.any_of({:locked => false},{:locked.exists => false},{:owner_id => current_user.id})
    else
      @documentation_documents = @documentation_documents.any_of({:locked => false},{:locked.exists => false})
    end

    @towns = use_cache controller_path do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

    @towns = @towns.select{ |t| params["town_select"].split(',').include? t.id.to_s } unless params["town_select"].blank?
  end
end
