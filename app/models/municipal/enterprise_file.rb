# frozen_string_literal: true

module Municipal
  # upload files for enterprise
  class EnterpriseFile
    include Mongoid::Document
    require 'carrierwave/mongoid'

    FORM_1 = '1'
    FORM_2 = '2'
    OTHER = '3'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader
    # used for update record with uploader
    # skip_callback :update, :before, :store_previous_model_for_file

    field :file_type, type: String
    field :year, type: Integer

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'
    belongs_to :owner, class_name: 'User'
    has_many :code_values, class_name: 'Municipal::CodeValue', dependent: :destroy

    validates_presence_of :enterprise, :file_type, :year, :file

    def self.type_files
      [
        { id: FORM_1, title: I18n.t('enterprise_files.type_files.form_1') },
        { id: FORM_2, title: I18n.t('enterprise_files.type_files.form_2') },
        { id: OTHER, title: I18n.t('enterprise_files.type_files.form_3') }
      ]
    end

    def self.by_town(town)
      enterprise_ids = Municipal::Enterprise.where(town: town).pluck(:id)
      where(:enterprise_id.in => enterprise_ids)
    end

    def self.reporting_chart(enterprise_id, code)
      return {} if code.blank?
      file_type = code.first.eql?(FORM_1) ? FORM_1 : FORM_2
      files = where(enterprise: enterprise_id, file_type: file_type)
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

    def self.analysis_chart(enterprise_id, code)
      return {} if code.blank?
      file_type = code[2].eql?(FORM_1) ? FORM_1 : FORM_2
      # files = where(enterprise: enterprise_id, file_type: file_type).order(year: :asc)
      files = where(enterprise: enterprise_id, :file_type.in => [FORM_1, FORM_2]).order(year: :asc)
      desc = Municipal::CodeDescription.where(code: code).first.try(:description)
      chart = {}
      chart[code] = { years: {}, desc: desc }

      code_info = get_code_info(code)

      years = { years: {} }

      files.each do |file|
        before_year = nil
        year = file.year
        # chart[code][:years]["c_#{year}"] = {} if chart[code][:years]["c_#{year}"].nil? #########
        years[:years]["c_#{year}"] = {} if years[:years]["c_#{year}"].nil? #########

        # code_info['f_codes'].each do |code_f|
        #   value_f = file.code_values.where(code: code_f).first.try(:value)
        #   # chart[code][:years]["c_#{year}"]["c_#{code_f}"] = value_f #########
        #   instance_variable_set("@c_#{code_f}", value_f.to_f)
        # end

        if code[1].eql?('1')
          code_info['f_codes'].each do |code_f|
            value_f = file.code_values.where(code: code_f).first.try(:value)
            # chart[code][:years]["c_#{year}"]["c_#{code_f}"] = value_f #########
            years[:years]["c_#{year}"]["c_#{code_f}"] = value_f #########

            before_year = years[:years]["c_#{year.to_i - 1}"]
            # chart[code][:years]["c_#{year}"]["svg_#{code_f}"] = before_year["c_#{code_f}"] + value_f / 2 if before_year #########
            binding.pry
            if before_year
              value_f2 = before_year["c_#{code_f}"] + value_f / 2 #########
              instance_variable_set("@c_#{code_f}", value_f2.to_f) if value_f2
            end
          end
        else
          if code[2].eql?('3') # 72301 >

          elsif code[2].eql?('5') # 72501 >
            if file.file_type.eql?('1')
              code_info['f_codes'].each do |code_f|
                if code_f[0].eql?('1')
                  value_f = file.code_values.where(code: code_f).first.try(:value)
                  # chart[code][:years]["c_#{year}"]["c_#{code_f}"] = value_f #########
                  years[:years]["c_#{year}"]["c_#{code_f}"] = value_f #########

                  before_year = years[:years]["c_#{year.to_i - 1}"]

                  # binding.pry
                  # chart[code][:years]["c_#{year}"]["svg_#{code_f}"] = before_year["c_#{code_f}"] + value_f / 2 if before_year #########
                  # binding.pry
                  if before_year
                    value_1 = before_year["c_#{code_f}"] #########
                    value_2 = value_f #########
                    instance_variable_set("@c1_#{code_f}", value_1.to_f) if value_1
                    instance_variable_set("@c2_#{code_f}", value_2.to_f) if value_2
                  end
                else
                  if before_year
                    value_f = file.code_values.where(code: code_f).first.try(:value)
                    # chart[code][:years]["c_#{year}"]["c_#{code_f}"] = value_f #########
                    instance_variable_set("@c_#{code_f}", value_f.to_f)
                  end
                end
              end

            else

            end

          end

        end

        binding.pry
        # Example code_info['formula'] = "(@c_2350/@c_2000)*100"
        chart[code][:years][year] = eval(code_info['formula']).try(:round, 2) if before_year
      end

      binding.pry
      chart
    end

    def self.get_code_info(code)
      require 'csv'
      csv_text = File.read('db/municipal/formula.csv')
      csv = CSV.parse(csv_text, headers: true, col_sep: ';')

      code_info = {}
      csv.each do |row|
        next unless row['code'].eql?(code)
        code_info['formula'] = row['formula']
        code_info['f_codes'] = row['f_codes'].split('|')
        code_info['abbreviation'] = row['abbreviation']
      end
      code_info
    end

  end
end
