module DowncaseField
  extend ActiveSupport::Concern

  module ClassMethods
    def downcase_gsub_str(str)
      str.mb_chars.downcase.gsub(/[^a-zA-ZА-Яа-я\-]/,"").to_s
    end
    def downcase_str(str)
      str.mb_chars.downcase.to_s
    end
  end
end
