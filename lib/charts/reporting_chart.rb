# frozen_string_literal: true

# not used
# previously used for api queries open_data_bot
module Charts
  # Build chart by enterprise reporting
  class ReportingChart
    def self.data_chart(enterprise_id, code)
      return {} if code.blank?
      file_type = code.first.eql?(Municipal::EnterpriseFile::FORM_1) ? Municipal::EnterpriseFile::FORM_1 : Municipal::EnterpriseFile::FORM_2
      files = Municipal::EnterpriseFile.where(enterprise: enterprise_id, file_type: file_type)
      desc = Municipal::CodeDescription.where(code: code).first.try(:description)
      chart = {}
      chart[code] = { years: {}, desc: desc }

      files.each do |file|
        year = file.year
        value = file.code_values.where(code: code).first.value

        chart[code][:years][year] = value
      end
      chart
    end
  end
end
