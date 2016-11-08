class String
  def valid_by_float?
    true if Float(self)
  end
end