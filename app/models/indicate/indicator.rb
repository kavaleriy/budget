class Indicate::Indicator
  include Mongoid::Document

  embedded_in :file, class_name: 'Indicate::File'

end
