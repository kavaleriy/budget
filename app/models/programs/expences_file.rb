class Programs::ExpencesFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String
  field :expences, type: Hash

  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true

  mount_uploader :expences_file, ExpencesFileUploader
  skip_callback :update, :before, :store_previous_model_for_expences_file

  validates_presence_of :expences_file, message: I18n.t('form.choose_file')

  def import table

    self.expences = {}

    table[:rows].each{|row|
      amount_plan = row['amount_plan'].to_i
      amount_fact = row['amount_fact'].to_i
      description = row['description']
      # binding.pry
      if row['phase'].blank? && row['year'].blank?
        self.expences['total'] = {} if self.expences['total'].nil?
        if row['sources'].blank?
          self.expences['total']['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['total']['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['total']['description'] = description unless description.blank?
        else
          self.expences['total']['sources'] = {} if self.expences['total']['sources'].blank?
          source = row['sources'].to_i.to_s
          self.expences['total']['sources'][source] = {} if self.expences['total']['sources'][source].blank?
          self.expences['total']['sources'][source]['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['total']['sources'][source]['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['total']['sources'][source]['description'] = description unless description.blank?
        end
      elsif row['year'].blank?
        phase = row['phase'].to_i.to_s
        self.expences['phases'] = {} if self.expences['phases'].blank?
        self.expences['phases'][phase] = {} if self.expences['phases'][phase].blank?
        self.expences['phases'][phase]['phase_start'] = row['phase_start'].to_i.to_s unless row['phase_start'].blank?
        self.expences['phases'][phase]['phase_end'] = row['phase_end'].to_i.to_s unless row['phase_end'].blank?
        if row['sources'].blank?
          self.expences['phases'][phase]['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['phases'][phase]['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['phases'][phase]['description'] = description unless description.blank?
        else
          source = row['sources'].to_i.to_s
          self.expences['phases'][phase]['sources'] = {} if self.expences['phases'][phase]['sources'].blank?
          self.expences['phases'][phase]['sources'][source] = {} if self.expences['phases'][phase]['sources'][source].blank?
          self.expences['phases'][phase]['sources'][source]['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['phases'][phase]['sources'][source]['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['phases'][phase]['sources'][source]['description'] = description unless description.blank?
        end
      else
        year = row['year'].to_i.to_s
        self.expences['years'] = {} if self.expences['years'].blank?
        self.expences['years'][year] = {} if self.expences['years'][year].blank?
        if row['sources'].blank?
          self.expences['years'][year]['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['years'][year]['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['years'][year]['description'] = description unless description.blank?
        else
          source = row['sources'].to_i.to_s
          self.expences['years'][year]['sources'] = {} if self.expences['years'][year]['sources'].blank?
          self.expences['years'][year]['sources'][source] = {} if self.expences['years'][year]['sources'][source].blank?
          self.expences['years'][year]['sources'][source]['amount_plan'] = amount_plan unless amount_plan == 0
          self.expences['years'][year]['sources'][source]['amount_fact'] = amount_fact unless amount_fact == 0
          self.expences['years'][year]['sources'][source]['description'] = description unless description.blank?
        end
      end

    }

  end

end
