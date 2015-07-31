class Public::DocumentsController < ApplicationController
  layout 'application_public'

  include ControllerCaching

  def index
    @documentation_documents = Documentation::Document
    @documentation_documents = @documentation_documents.where(:town.in => params["town_select"].split(',')) unless params["town_select"].blank?
    @documentation_documents = @documentation_documents.where(:branch.in => params["branch_select"]) unless params["branch_select"].blank?
    @documentation_documents = @documentation_documents.where(:yearFrom.lte => params["year"].to_i, :yearTo.gte => params["year"].to_i) unless params["year"].blank?
    @documentation_documents = @documentation_documents.where(:title => Regexp.new(".*"+params["q"]+".*")) unless params["q"].blank?

    @towns = use_cache do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

  end

end
