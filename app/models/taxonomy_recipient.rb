class TaxonomyRecipient
  include Mongoid::Document

  default_scope lambda { order_by(:code => :asc) }

  embedded_in :taxonomy, inverse_of: :recipients

  field :code, type: String
  field :amount, type: Integer
end
