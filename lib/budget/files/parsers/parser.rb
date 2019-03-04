module Budget
  module Files
    module Parsers
      class Parser
        def initialize(file, koatuu)
          @file = file
          @koatuu = koatuu
          file_name_without_ext = file.original_filename.split('.').first
          @month = file_name_without_ext.split('-').last.to_i
          @year = file_name_without_ext.split('-')[-2].to_i
          @json = JSON.parse(file.read)

        end
      end
    end
  end 
end
