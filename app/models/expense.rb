class Expense < BudgetFile
  include Mongoid::Document

  def load_file
    require 'dbf'

    dbf = DBF::Table.new(self.file)

    # load taxonomies
    self.taxonomies = get_taxonomies %w(kvk kekv ktfk)

    self.rows = []

    dbf.reject { |rec| rec.summ.nil? || rec.summ == 0 }.each do |rec|
      kvk = rec.kvk.to_s
      #krk = rec.krk.to_s
      ktfk = rec.ktfk.to_s
      #ktfk_aaa = ktfk.slice(0, 3)
      #ktfk_bbb = ktfk.slice(0, 6)
      kekv = rec.kekv.to_s
      amount = rec.summ / 100
      self.rows << { 'kvk' => kvk, 'kekv' => kekv, 'ktfk' => ktfk, amount: amount }
    end
  end

  protected
    #def get_burst_for(rows, nodes)
    #  children = []
    #  small = { "count" => 0, "amount" => 0 }
    #  nodes.each do |node|
    #    rows.reject {|r| r[:ktfk] != node}.each do |r|
    #      if r[:amount] > 200000000
    #        children << { "name" => r[:ktfk], "size" => r[:amount]}
    #      else
    #        small["count"] += 1
    #        small["amount"] += r[:amount]
    #      end
    #    end
    #  end
    #
    #  if small["amount"] > 0
    #    children << { "name" => "АГРЕГОВАНО: #{small['count']} показників", "size" => small['amount']}
    #  end
    #
    #  children
    #end

end
