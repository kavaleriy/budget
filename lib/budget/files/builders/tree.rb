module Budget
  module Files
    module Builders
      class Tree

        def initialize(files, column)
          @year = '2019'
          @files = files.to_a
          @column = column
          @res = build_scelleton
          @grouped_by_income_files = files.group_by{|a| a.income_code}
        end

        def call
          @files.group_by{|a| a.month}.each do |month, values|
            @res[:amount][:plan][@year][month] = {
              # total: values.sum{|val| val.budget_plan.to_f},
              total: 1,
              fonds:{
                '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.budget_plan.to_f},
                '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.budget_plan.to_f}
              }
            } 
            @res[:amount][:fact][@year][month] = {
              total: 1,
              # total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.total_done.to_f},
              fonds:{
                '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.total_done.to_f},
                '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.total_done.to_f}
              }
            } 
          end
          @res[:label] = 'Всього'
          @res[:key] = 'Всього'
          @res[:icon] = '/assets/icons/pig.svg'
          @res[:color] = 'green'
          @files.select{|file| file.public_send(@column) =~ level_regex(0)[:regex]}.group_by{|file| file.public_send(@column)}.each do |key, files|
            @res[:children] << build_tree(files, 1, key)
          end
          @res
        end

        private 

        def build_scelleton
          {
            amount: {
              fact: {
                @year => {}
              },
              plan: {
                @year => {}
              }
            },
            label: '',
            key: '',
            children: [],
            taxonomy: 'kkd_a'
          }
        end



        def fill_amount_data(grouped_files_by_month)
          tmp = build_scelleton
          grouped_files_by_month.each do |month, values|
            tmp[:amount][:plan][@year][month] = {
              total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.budget_plan.to_f},
              fonds:{
                '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.budget_plan.to_f},
                '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.budget_plan.to_f}
              }
            } 
            tmp[:amount][:fact][@year][month] = {
              total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.total_done.to_f},
              fonds:{
                '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.total_done.to_f},
                '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.total_done.to_f}
              }
            } 
          end
          tmp
        end

        def level_regex(level, file_key='')
          if level == 0
            regex = '[0]{7}$'
          elsif level == 1
            regex = file_key.blank? ? '[0]{7}$' : "[0]{#{file_key.size - level - 1}}$"
            level += 1
          else
            regex = "[0]{#{file_key.size - (level * 2)}}$"
            level += 2
          end
          { level: level, regex: Regexp.new(regex) }
        end

        def build_tree(grouped_files, level = 0, file_key = '')
          regex = level_regex(level)
          tmp = {}
          grouped_files.group_by{|file| file.public_send(@column)}.each do |key, grouped_by_column|
            file_key = key
            tmp = fill_amount_data(grouped_by_column.group_by{|a| a.month})
            tmp[:label] = grouped_by_column.first.income_code_name
            tmp[:key] = key
            child_regex = Regexp.new("[0]{#{file_key.size - (level * 2)}}$")
            child_tmp = []
            children = @grouped_by_income_files.keys.select{|file| file.start_with?(file_key[0...level]) && file =~ child_regex && file != file_key}
            children.each do |child_key|
              child = build_tree(@grouped_by_income_files[child_key], regex[:level], child_key)
              child_tmp << child
            end
            tmp[:children] = child_tmp
          end
          tmp
        end

      end
    end
    
  end 
end