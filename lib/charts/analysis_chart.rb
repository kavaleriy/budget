# frozen_string_literal: true

# not used
# previously used for api queries open_data_bot
module Charts
  # Build chart by enterprise reporting
  class AnalysisChart
    def self.data_chart(enterprise_id, codes)
      line_chart = []

      codes.each do |code|
        return {} if code.blank?
        line_chart << build_line(enterprise_id, code)
      end
      line_chart
    end

    def self.build_line(enterprise_id, code)
      enterprise_type = Municipal::Enterprise.find(enterprise_id).try(:reporting_type)
      code_formula_info = get_code_info(enterprise_type, code)
      file_types = file_types(code[2])

      files = Municipal::EnterpriseFile.where(enterprise: enterprise_id, :file_type.in => file_types).order(year: :asc)
      code_info = Municipal::CodeDescription.where(code: code).first
      chart = {}
      chart[code] = {
        years: {},
        desc: code_info.try(:description),
        title: code_info.try(:title),
        # abbr: code_formula_info['abbreviation'],
        unit: code_info.try(:unit)
      }

      years = {}

      files.each do |file|
        year = file.year
        years[year] = {} unless years[year]

        if code_formula_info['f_codes'].present?
          code_formula_info['f_codes'].each do |code_f|
            # TODO: Put all formules to classes imediatly!!!

            value_f = file.code_values.where(code: code_f).first.try(:value)

            if code_f == '2350' && value_f == 0
              code_f = '2355'
              value_f = file.code_values.where(code: code_f).first.try(:value)
            elsif code_f == '2190' && value_f == 0
              code_f = '2195'
              value_f = file.code_values.where(code: code_f).first.try(:value)
            end

            years[year][code_f] = value_f if value_f
            # {2015=>{"1495"=>5353}, 2016=>{"1495"=>5353, "2350"=>71}, 2017=>{"1495"=>5296, "2350"=>283}}
          end
        end
      end

      years.each do |year_k, year_v|
        before_year = nil

        code_formula_info['codes_1_year'].each do |code_f|
          instance_variable_set("@c_#{code_f}", year_v[code_f].to_f)
        end if code_formula_info['codes_1_year'].present?

        code_formula_info['codes_2_year'].each do |code_f|
          before_year = years[year_k]
          instance_variable_set("@c1_#{code_f}", year_v[code_f].to_f)
          instance_variable_set("@c2_#{code_f}", before_year[code_f].to_f)
        end if code_formula_info['codes_2_year'].present?

        chart[code][:years][year_k] = eval(code_formula_info['formula']).try(:round, 3) if before_year || code_formula_info['codes_2_year'].present?
      end

      chart
    end

    def self.get_code_info(enterprise_type, code)
      require 'csv'
      csv_text = File.read("db/municipal/#{enterprise_type}_formula.csv")
      csv = CSV.parse(csv_text, headers: true, col_sep: ';')

      code_info = {}
      csv.each do |row|
        next unless row['code'].eql?(code)
        code_info['formula'] = row['formula']
        code_info['abbreviation'] = row['abbreviation']
        code_info['codes_1_year'] = row['codes_1_year'].split('|').reject(&:blank?) if row['codes_1_year']
        code_info['codes_2_year'] = row['codes_2_year'].split('|').reject(&:blank?) if row['codes_2_year']
        code_info['f_codes'] = (code_info['codes_1_year'] + code_info['codes_2_year'])
      end
      code_info

    end

    def self.file_types(type)
      case type
      when '1' then [Municipal::EnterpriseFile::FORM_1]
      when '2' then [Municipal::EnterpriseFile::FORM_2]
      when '3' then [Municipal::EnterpriseFile::FORM_1, Municipal::EnterpriseFile::FORM_2]
      end
    end

  end
end
