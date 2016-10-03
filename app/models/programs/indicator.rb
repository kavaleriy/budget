class Programs::Indicator
  include Mongoid::Document

  EXPENSES_TYPE = 1
  PRODUCT_TYPE = 2
  EFECTIVE_TYPE = 3
  QUALITY_TYPE = 4

  field :title_program,      type: String
  field :title,              type: String
  field :group,              type: String
  field :measurement_unit,   type: String
  field :value,              type: Hash
  field :source_information, type: String
  # field :year,              type: String

  belongs_to :targeted_program, class_name: 'Programs::TargetedProgram', index: true

  def self.create_indicators_by_xls(sheet, prog)

    unless sheet.nil?
      indicates_hash = XlsParser.get_table_hash(sheet)

      indicates_hash.each do |indicate_hash|
        tmp = {
             plan: indicate_hash.delete('value_plan'),
             fact: indicate_hash.delete('value_fact'),
             differences: indicate_hash.delete('value_differences')
            }
        indicator = self.new(indicate_hash)
        indicator.value = tmp
        indicator.targeted_program = prog
        indicator.save

      end
    end

  end

  def self.set_indicator_group_name(key)
    case key.to_i
      when EXPENSES_TYPE then 'expense'
      when PRODUCT_TYPE then 'product'
      when EFECTIVE_TYPE then 'efective'
      when QUALITY_TYPE then 'quality'
      else
        'other'
    end
  end
end
