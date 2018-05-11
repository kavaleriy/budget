# frozen_string_literal: true

module StatusCode
  # Build code statuses by enterprise reporting
  class SetStatus
    def self.generate_statuses(enterprise_file)
      report_files = Municipal::EnterpriseFile.where(enterprise: enterprise_file.enterprise, file_type: enterprise_file.file_type).order(year: :desc)
      return unless report_files.size >= 2

      if enterprise_file.year >= report_files.second.try(:year)
        # set form 1, form 2 chart status
        # set analysis chart
        reports_statuses(enterprise_file, report_files)
        binding.pry
        analysis_statuses(enterprise_file)
        binding.pry
      elsif (report_files.size > 2) && (enterprise_file.year >= report_files.third.try(:year))
        # set analysis chart status
        p "#########  set analysis chart status 2"
        analysis_statuses(enterprise_file)
        binding.pry
      end
    end

    def self.reports_statuses(enterprise_file, report_files)
      p "#########  set reports chart status"
      codes = reports_code_values(report_files.first, report_files.second)

      codes.each do |code|
        save_status(code, enterprise_file.enterprise)
      end
    end

    def self.analysis_statuses(enterprise_file)
      p "#########  set analysis chart status 1"
      analysis_codes = Municipal::GuideFilter.by_type(enterprise_file.enterprise.reporting_type, 3).first.codes.pluck(:code)
      analysis_values = Charts::AnalysisChart.data_chart(enterprise_file.enterprise, analysis_codes)

      codes = analysis_code_values(analysis_values)
      codes.each do |code|
        save_status(code, enterprise_file.enterprise)
      end
    end

    def self.reports_code_values(file_1, file_2)
      codes = {}
      file_1.code_values.each do |code|
        codes[code.code] = []
        codes[code.code].push(code.value)
        p "code - #{code.code}, value - #{code.value}"
      end
      file_2.code_values.each do |code|
        codes[code.code] = [] unless codes.key?(code.code)
        codes[code.code].try(:push, code.value)
        p "code - #{code.code}, value - #{code.value}"
      end

      codes
    end

    def self.analysis_code_values(analysis_values)
      codes = {}
      analysis_values.each do |value|
        values = value.values[0][:years].values
        next unless zero_or_infinite?(values[-1]) && zero_or_infinite?(values[-2])

        codes[value.keys[0]] = []
        codes[value.keys[0]].try(:push, values[-1])
        codes[value.keys[0]].try(:push, values[-2])
      end

      codes
    end

    def self.zero_or_infinite?(value)
      value.finite? && !value.zero?
    end

    def self.save_status(code, enterprise)
      code_type = code[0].first.eql?('7') ? 3 : code[0].first
      status = Municipal::CodeStatus.find_or_initialize_by(enterprise: enterprise, code: code[0], reporting_type: code_type)
      values = code[1]

      return if values[0].blank? && values[1].blank?

      status_type =
        if values[0].to_i > values[1].to_i
          p "#{code[0]} - up!"
          :up
        elsif values[0].to_i == values[1].to_i
          p "#{code[0]} - some!"
          :some
        elsif values[0].to_i < values[1].to_i
          p "#{code[0]} - down!"
          :down
        end

      status.status = status_type
      p "#{code[0]} code - #{values[0]}, #{values[1]}"
      p status
      status.save
    end
  end
end
