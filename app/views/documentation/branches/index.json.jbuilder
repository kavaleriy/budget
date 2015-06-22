json.array!(@documentation_branches) do |documentation_branch|
  json.extract! documentation_branch, :id, :name
  json.url documentation_branch_url(documentation_branch, format: :json)
end
