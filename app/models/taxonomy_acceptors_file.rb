class TaxonomyAcceptorsFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :rows, :type => Hash

  belongs_to :taxonomy, :class_name => 'Taxonomy', autosave: true

  mount_uploader :acceptors_file, TaxonomyAcceptorsFileUploader
  skip_callback :update, :before, :store_previous_model_for_acceptors_file

  validates_presence_of :acceptors_file, message: I18n.t('form.choose_file')

  def import table
    table[:rows].each{|row|
      year = row['year'].to_i.to_s
      self.rows = {} if self.rows.nil?
      self.rows[year] = [] if self.rows[year].nil?

      kod = row['code'].to_s.split('.')[0].gsub(/^0*/, "")
      if kod.length > 4 || @ktfk.nil?
        @ktfk = kod
      else
        kekv = kod
      end

      ktfk = @ktfk
      ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
      ktfk_aaa = '80' if ktfk_aaa == '81'
      ktfk_aaa = '90' if ktfk_aaa == '91'

      self.rows[year] << {'amount' => row['amount'],
                          'acceptor' => row['acceptor'],
                          'ktfk' => ktfk,
                          'ktfk_aaa' => ktfk_aaa,
                          'kekv' => kekv
                         }
    }
    self.save
  end

end
