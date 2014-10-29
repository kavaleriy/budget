#encoding: utf-8

require 'csv'

namespace :budget_codes do

  desc "Load data from revenues.csv"
  task :load_revenue_codes => :environment do
    RevenueCode.delete_all

    CSV.foreach('db/revenue_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
      RevenueCode.create!(kkd: row[0], title: row[1])
    end
  end

  desc "Load data from expense.csv"
  task :load_expense_codes => :environment do
    ExpenseCode.delete_all

    CSV.foreach('db/expense_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
      ExpenseCode.create!(ktfk: row[0], title: row[1])
    end
  end
end
