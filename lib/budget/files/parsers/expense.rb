module Budget
  module Files
    module Parsers
      class Expense < Parser

        def parse
          
          @json.each do |data|
            hash = {
              year: @year,
              month: @month,
              fund_type: data['fundType'],
              program_code: data['programCode'],
              program_code_name: data['programCodeName'],
              function_code: data['functionCode'],
              function_code_name: data['functionCodeName'],
              economic_code: data['economicCode'],
              economic_code_name: data['economicCodeName'],
              budget_plan: data['yearBudgetPlan'].to_f,
              budget_estimate: data['yearBudgetEstimate'].to_f,
              total_done: data['totalDone'].to_f,
              percent_done: data['percentDone'].to_f,
              done_special_fund: data['doneSpecialFund'].to_f,
              done_service: data['doneService'],
              done_other: data['doneOther'],
              total_bank_account: data['totalBankAccount'],
              bank_special_fund: data['bankSpecialFund'],
              bank_service: data['bankService'],
              bank_other: data['bankOther'],
              koatuu: @koatuu
            }
            Budget::GovFiles::Expense.create!(hash)
          end
        end
      end
    end
    
  end 
end