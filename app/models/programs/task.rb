class Programs::Task
  include Mongoid::Document

  field :title,type: String
  field :general_fund, type: String
  field :special_fund, type: String
  field :group_num,type: String
  field :sum, type: String

  def self.create_tasks_by_xls(sheet)
    unless sheet.nil?
      res_tasks = []
      tasks_hash = XlsParser.get_table_hash(sheet)
      tasks_hash.each do |task_hash|
        res_tasks << self.create(task_hash)
      end

    end
  end

end
