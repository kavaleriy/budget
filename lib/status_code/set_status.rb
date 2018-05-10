# frozen_string_literal: true

module StatusCode
  # Build code statuses by enterprise reporting
  class SetStatus
    def self.generate_statuses(enterprise_file)
      ent_files_by_type = Municipal::EnterpriseFile.where(enterprise: enterprise_file.enterprise, file_type: enterprise_file.file_type).order(year: :desc)
      return unless ent_files_by_type.size >= 2

      if enterprise_file.year >= ent_files_by_type.second.try(:year)
        # set form 1, form 2 chart status
        # set analysis chart
        p "#########  set form 1, form 2 chart status"
        codes = code_values(ent_files_by_type.first, ent_files_by_type.second)

        codes.each do |code|
          save_status(code, enterprise_file.enterprise)
        end
        binding.pry
      end

      if enterprise_file.year >= ent_files_by_type.third.try(:year)
        # set analysis chart status
        p "#########  set analysis chart status"
      end

    end

    def self.code_values(file_1, file_2)
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

    def self.save_status(code, enterprise)
      # status = Municipal::CodeStatus.new(enterprise: enterprise, code_number: code[0])
      status = Municipal::CodeStatus.find_or_initialize_by(enterprise: enterprise, code_number: code[0])
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
      # status.save
    end

  end
end
