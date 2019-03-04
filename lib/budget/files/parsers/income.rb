module Budget
  module Files
    module Parsers
      class Income < Parser

        def parse
          @json.each do |data|
            hash = {
              year: @year,
              month: @month,
              fund_type: data['fundType'],
              income_code: data['incomeCode'],
              income_code_name: data['incomeCodeName'],
              budget_plan: data['yearBudgetPlan'].to_f,
              budget_estimate: data['yearBudgetEstimate'].to_f,
              total_done: data['totalDone'].to_f,
              percent_done: data['percentDone'].to_f,
              koatuu: @koatuu
            }
            Budget::GovFiles::Income.create!(hash)
          end
        end
      end
    end
    
  end 
end
