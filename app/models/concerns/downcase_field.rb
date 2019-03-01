module DowncaseField
  extend ActiveSupport::Concern

  module ClassMethods
    def downcaseStr(str)
      str.mb_chars.downcase.to_s
    end
  end
end
