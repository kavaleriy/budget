# #encoding: utf-8
#
# require 'csv'
#
# namespace :budget_codes do
#
#   desc "Load data from revenues.csv"
#   task :load_revenue_codes => :environment do
#     RevenueCode.delete_all
#
#     CSV.foreach('db/revenue_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
#       RevenueCode.create!(kkd: row[0], title: row[1])
#     end
#   end
#
#   desc "Load data from expense.csv"
#   task :load_expense_codes => :environment do
#     ExpenseCode.delete_all
#
#     CSV.foreach('db/expense_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
#       ExpenseCode.create!(ktfk: row[0], title: row[1])
#     end
#   end
#
#   desc "Load data from expense_ekv.csv"
#   task :load_expense_ekv_codes => :environment do
#     ExpenseEkvCode.delete_all
#
#     CSV.foreach('db/expense_ekv_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
#       ExpenseEkvCode.create!(ekv: row[0], title: row[1])
#     end
#   end
#
#   desc "Load data from expense_kvk.csv"
#   task :load_expense_kvk_codes => :environment do
#     ExpenseKvkCode.delete_all
#
#     CSV.foreach('db/expense_kvk_codes.csv', {:headers => true, :col_sep => ";"}) do |row|
#       ExpenseKvkCode.create!(kvk: row[0].strip, title: row[1].strip)
#     end
#   end
# end
