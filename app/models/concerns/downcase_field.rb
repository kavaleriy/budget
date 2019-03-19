module DowncaseField
  extend ActiveSupport::Concern

  module ClassMethods
    def downcase_str(str)
      str.mb_chars.downcase.gsub(/[^a-zA-ZА-Яа-я\-]/,"").to_s
    end
  end
end
