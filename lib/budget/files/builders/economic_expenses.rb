require 'budget/files/builders/economic_expenses'
module Budget
  module Files
    module Builders
      class EconomicExpenses < Tree
        protected 

        def level_regex(level, file_key='')
          if level == 0
            regex = "[0]{#{@bit_depth - 1}}$"
          elsif level == 1
            regex = file_key.blank? ? '[0]{2}$' : "[0]{#{file_key.size - level - 1}}$"
            level += 1
          else
            regex = "[0]{#{file_key.size - (level * 2)}}$"
            level += 2
          end
          { level: level, regex: Regexp.new(regex) }
        end
      end
    end
  end
end