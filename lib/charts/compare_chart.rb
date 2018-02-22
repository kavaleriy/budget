# frozen_string_literal: true

# not used
# previously used for api queries open_data_bot
module Charts
  # Build chart by enterprise reporting
  class CompareChart
    def self.data_chart(enterprises, code)
      line_chart = []

      enterprises.each do |ent|
        line_chart << build_line(ent, code)
      end
      line_chart
    end

    def self.build_line(enterprise, code)
      code_type = code.first
      ent_data = { title: enterprise.title, id: enterprise.id.to_s }
      line = case code_type
             when '1', '2'
               Charts::ReportingChart.build_line(enterprise, code)
             when '7'
               Charts::AnalysisChart.build_line(enterprise, code)
             end
      line.merge(ent_data)
    end
  end
end
