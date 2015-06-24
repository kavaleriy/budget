json.array!(@documentation_documents) do |documentation_document|
  json.extract! documentation_document, :id, :category, :title
  json.url documentation_document_url(documentation_document, format: :json)
end
