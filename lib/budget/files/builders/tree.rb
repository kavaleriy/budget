module Budget
  module Files
    module Builders
      class Tree

        def initialize(files, column)
          @files = files.to_a
          @column = column
          @res = build_scelleton
          @grouped_by_income_files = files.group_by{|a| a.income_code}
        end

        def call
          
          @files.group_by{|a| a.month}.each do |month, values|
            @res[:amount][:plan]['2018'][month] = {
              total: values.sum{|val| val.budget_plan.to_f},
              fonds:{
                '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.budget_plan.to_f},
                '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.budget_plan.to_f}
              }
            } 
            @res[:amount][:fact]['2018'][month] = {
              total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.total_done.to_f},
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
          @res[:children] = build_tree(@files)
          @res
        end


        private 

        def build_scelleton
          {
            amount: {
              fact: {
                '2018' => {}
              },
              plan: {
                '2018' => {}
              }
            },
            label: '',
            key: '',
            children: []
          }
        end

        def build_tree(grouped_files, level = 0, file_key = '')
          if level <= 1
            regex = file_key.blank? ? '[0]{7}$' : "[0]{#{file_key.size - level - 1}}$"
            level += 1
          else
            regex = "[0]{#{file_key.size - (level * 2)}}$"
            level += 2
            # binding.pry
          end
          regex = Regexp.new(regex)
          tree = []
          grouped_files.select{|file| file.public_send(@column) =~ regex}.group_by{|file| file.public_send(@column)}.each do |key, grouped_by_column|
            file_key = key
            grouped_files_by_month = grouped_by_column.group_by{|a| a.month}
            tmp = build_scelleton
            grouped_files_by_month.each do |month, values|
              tmp[:amount][:plan]['2018'][month] = {
                total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.budget_plan.to_f},
                fonds:{
                  '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.budget_plan.to_f},
                  '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.budget_plan.to_f}
                }
              } 
              tmp[:amount][:fact]['2018'][month] = {
                total: values.select{|val| val.fund_type == 'TOTAL'}.sum{|val| val.total_done.to_f},
                fonds:{
                  '1' => values.select{|val| val.fund_type == 'COMMON'}.sum{|val| val.total_done.to_f},
                  '2' => values.select{|val| val.fund_type == 'SPECIAL'}.sum{|val| val.total_done.to_f}
                }
              } 
              
            end
            tmp[:label] = grouped_by_column.first.income_code_name
            tmp[:key] = key
            child_regex = Regexp.new("[0]{#{file_key.size - (level * 2)}}$")
            children = @grouped_by_income_files.keys.select{|file| file.start_with?(file_key[0...level]) && file =~ child_regex && file != file_key}
            children.each do |child_key|
              tmp[:children] << build_tree(@grouped_by_income_files[child_key], level, child_key)
            end

            tree << tmp
          end
          tree
        end

      end
    end
    
  end 
end