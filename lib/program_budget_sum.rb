module ProgramBudgetSum

  class ProgramBudgetSumHash
    attr_accessor :sum_hash
    def initialize
      @sum_hash = {
          plan: {
              general_fund: 0.0,
              special_fund: 0.0,
              sum: 0.0,
          },
          fact: {
              general_fund: 0.0,
              special_fund: 0.0,
              sum: 0.0,

          },
          differences: {
              general_fund: 0.0,
              special_fund: 0.0,
              sum: 0.0
          }
      }
    end

    def sum_hash=(program_hash)
      budget_plan_sum_name_arr = %w(general_fund_plan special_fund_plan sum_plan general_fund_fact special_fund_fact sum_fact)
      budget_diff_name_arr = %w( differences_general_fund differences_special_fund differences_sum)

      budget_plan_sum_name_arr.each do |name|
        # get category name (example general_fund_plan = plan)
        category = name.last(4)
        # store value where key name without category and underscore, value find by name
        @sum_hash[category.to_sym].store(name.gsub("_#{category}",'').to_sym, program_hash[name].to_f)
        # remove value by name from hash
        program_hash.except!(name)
      end

      budget_diff_name_arr.each do |diff|
        # get category name (example differences_general_fund = differences)
        category = diff.split('_').first
        # store value where key name without category and underscore, value find by name
        @sum_hash[category.to_sym].store(diff.gsub("#{category}_",'').to_sym, program_hash[diff].to_f)
        # remove value by name from hash
        program_hash.except!(diff)
      end
    end

  end




end