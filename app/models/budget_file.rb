class BudgetFile
  include Mongoid::Document

  field :title, type: String
  field :file, type: String


  def get_revenue_codes
    load_from_csv 'db/revenue_codes.csv'
  end

  def get_expense_codes
    load_from_csv 'db/expense_codes.csv'
  end

  def get_expense_ekv_codes
    load_from_csv 'db/expense_ekv_codes.csv'
  end

  def get_expense_kvk_codes
    load_from_csv 'db/expense_kvk_codes.csv'
  end

  protected
    def load_from_csv file_name
      items = {}
      CSV.foreach('db/revenue_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
        items[row[0]] = row[1]
      end
      items
    end
end
