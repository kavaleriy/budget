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

end
