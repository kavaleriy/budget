module Budget
  module Files
    module Builders
      class Tree

        def initialize(files, column, year, label_field, total_plan_column, total_fact_column)
          @files = files.to_a
          @column = column
          @year = year
          @label_field = 'income_code_name'
          @total_plan_column = 'budget_plan'
          @total_fact_column = 'total_done'
          
          @grouped_files_by_code = files.group_by{|file| file.public_send(@column)}
          @res = build_scelleton
        end

        def call
          @files.group_by{|a| a.month}.each do |month, values|
            month = month - 1
            @res[:amount][:plan][@year][month + 1] = {
              total: find_total_plan(month, values),
              fonds:{
                '1' => find_plan_total_by_common_fond(month, values),
                '7' => find_plan_total_by_special_fond(month, values)
              }

            } 
            @res[:amount][:fact][@year][month + 1] = {
              total: find_total_fact(month, values),
              fonds:{
                '1' => find_fact_total_by_common_fond(month, values),
                '7' => find_fact_total_by_special_fond(month, values)
              }
            } 
          end
          @res[:amount][:plan][@year][0] = @res[:amount][:plan][@year].values.last
          @res[:amount][:fact][@year][0] = @res[:amount][:fact][@year].values.last
          @res[:amount][:plan][@year]['_cumulative'] = false
          # @res[:amount][:fact][@year]['_cumulative'] = true
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
            taxonomy: '-'
          }
        end



        def fill_amount_data(grouped_files_by_month)
          tmp = build_scelleton
          grouped_files_by_month.each do |month, values|
            tmp[:amount][:plan][@year][month] = {
              total: total_values_by_month(month, 'TOTAL', values, 'budget_plan', grouped_files_by_month[month-1]),
              fonds:{ 
                '1' => total_values_by_month(month, 'COMMON', values, 'budget_plan', grouped_files_by_month[month-1]),
                '2' => total_values_by_month(month, 'SPECIAL', values, 'budget_plan', grouped_files_by_month[month-1])
              }
            } 
            tmp[:amount][:fact][@year][month] = {
              total: total_values_by_month(month, 'TOTAL', values, 'total_done', grouped_files_by_month[month-1]),
              fonds:{
                '1' => total_values_by_month(month, 'COMMON', values, 'total_done', grouped_files_by_month[month-1]),
                '2' => total_values_by_month(month, 'SPECIAL', values, 'total_done', grouped_files_by_month[month-1])
              }
            } 
          end
          tmp[:amount][:plan][@year][0] = tmp[:amount][:plan][@year].values.last
          tmp[:amount][:fact][@year][0] = tmp[:amount][:fact][@year].values.last
          tmp[:amount][:plan][@year]['_cumulative'] = false
          # tmp[:amount][:fact][@year]['_cumulative'] = true
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
            tmp[:label] = grouped_by_column.first.public_send(@label_field)
            tmp[:key] = key
            child_regex = Regexp.new("[0]{#{file_key.size - (level * 2)}}$")
            child_tmp = []
            children = @grouped_files_by_code.keys.select{|file| file.start_with?(file_key[0...level]) && file =~ child_regex && file != file_key}
            children.each do |child_key|
              child = build_tree(@grouped_files_by_code[child_key], regex[:level], child_key)
              child_tmp << child
            end
            tmp[:children] = child_tmp
          end
          tmp
        end

        def find_total_plan(month, values)
          values.uniq{|a| a.income_code}.select{|a| a.income_code =~ level_regex(0)[:regex]}.sum{|a| a.public_send(@total_plan_column)}
         end

        def find_total_fact(month, values)
          values.uniq{|a| a.income_code}.select{|a| a.income_code =~ level_regex(0)[:regex]}.sum{|val| val.public_send(@total_fact_column).to_f}
        end
        
        def find_plan_total_by_common_fond(month, values)
          values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.public_send(@total_plan_column).to_f}
        end
        
        def find_fact_total_by_common_fond(month, values)
          values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.public_send(@total_fact_column).to_f}
        end

        def find_fact_total_by_special_fond(month, values)
          values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.public_send(@total_fact_column).to_f}
        end

        def find_plan_total_by_special_fond(month, values)
          values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.public_send(@total_plan_column).to_f}
        end

        def total_values_by_month(month, fund_type, values, sum_column, previous_data)
          values.select{|val| val.fund_type == fund_type}.sum{|val| val.public_send(sum_column).to_f}
        end
      
      end
    end
  end 
end