json.array!(@transactions) do |transaction|
  json.extract! transaction, :id, :kvk, :kfk, :kekv, :amount
  json.url transaction_url(transaction, format: :json)
end
