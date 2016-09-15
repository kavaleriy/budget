class Programs::Task
  include Mongoid::Document

  field :title,         type: String
  field :general_fund,  type: String
  field :special_fund,  type: String
  field :group_num,     type: String
  field :sum,           type: String

  belongs_to :targeted_program, class_name: 'Programs::TargetedProgram', index: true

  def self.create_tasks_by_xls(sheet, prog)

    unless sheet.nil?
      tasks_hash = XlsParser.get_table_hash(sheet)

      tasks_hash.each do |task_hash|
        task = self.create(task_hash)
        task.targeted_program = prog
        task.save
      end

    end
  end

end
