# frozen_string_literal: true

# not used
# previously used for api queries open_data_bot
module Charts
  # Build chart by enterprise reporting
  class ReportingChart
    def self.data_charts(enterprise_id, codes)
      line_chart = []

      codes.each do |code|
        return {} if code.blank?
        line_chart << build_line(enterprise_id, code)
      end
      line_chart
    end

    def self.build_line(enterprise_id, code)
      return {} if code.blank?
      file_type = code.first.eql?(Municipal::EnterpriseFile::FORM_1) ? Municipal::EnterpriseFile::FORM_1 : Municipal::EnterpriseFile::FORM_2
      files = Municipal::EnterpriseFile.where(enterprise: enterprise_id, file_type: file_type)
      code_info = Municipal::CodeDescription.where(code: code).first
      title = code_info.try(:title)
      desc = code_info.try(:description)
      unit = code_info.try(:unit)
      chart = {}
      chart[code] = {
        years: {},
        desc: desc,
        title: title,
        unit: unit
      }

      files.each do |file|
        year = file.year
        value = file.code_values.where(code: code).first.value

        chart[code][:years][year] = value
      end
      chart
    end
  end
end
