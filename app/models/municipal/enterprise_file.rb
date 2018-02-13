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

    def self.analysis_chart(enterprise_id, codes)
      line_chart = []

      codes.each do |code|
        return {} if code.blank?
        line_chart << build_line(enterprise_id, code)
      end
      line_chart
    end

    def self.build_line(enterprise_id, code)
      # file_type = code[2].eql?(FORM_1) ? FORM_1 : FORM_2
      # files = where(enterprise: enterprise_id, file_type: file_type).order(year: :asc)
      code_info = get_code_info(code)
      files = where(enterprise: enterprise_id, :file_type.in => [FORM_1, FORM_2]).order(year: :asc)
      desc = Municipal::CodeDescription.where(code: code).first
      chart = {}
      chart[code] = { years: {}, desc: desc.try(:description), title: desc.try(:title), abbr: code_info['abbreviation'] }


      years = {}
      files.each do |file|
        year = file.year
        years[year] = {} unless years[year]

        code_info['f_codes'].each do |code_f|
          value_f = file.code_values.where(code: code_f).first.try(:value)
          years[year][code_f] = value_f if value_f
          # {2015=>{"1495"=>5353}, 2016=>{"1495"=>5353, "2350"=>71}, 2017=>{"1495"=>5296, "2350"=>283}}
        end
      end

      years.each do |year_k, year_v|
        before_year = nil

        code_info['codes_1_year'].each do |code_f|
          instance_variable_set("@c_#{code_f}", year_v[code_f].to_f)
        end if code_info['codes_1_year'].present?

        code_info['codes_2_year'].each do |code_f|
          before_year = years[year_k]
          instance_variable_set("@c1_#{code_f}", year_v[code_f].to_f)
          instance_variable_set("@c2_#{code_f}", before_year[code_f].to_f)
        end if code_info['codes_2_year'].present?

        # binding.pry
        chart[code][:years][year_k] = eval(code_info['formula']).try(:round, 3) if before_year || !code_info['codes_2_year'].present?
      end

      # binding.pry
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
        code_info['abbreviation'] = row['abbreviation']
        code_info['codes_1_year'] = row['codes_1_year'].split('|').reject(&:blank?) if row['codes_1_year']
        code_info['codes_2_year'] = row['codes_2_year'].split('|').reject(&:blank?) if row['codes_2_year']
        code_info['f_codes'] = (code_info['codes_1_year'] + code_info['codes_2_year'])
      end
      code_info
    end

  end
end
