class Modules::Classifier
  include Mongoid::Document

  K_FORM_STATE_POWER = 410

  field :sk_ter, type: Integer
  field :kvk, type: Integer
  field :rkrk, type: String
  field :edrpou, type: String
  field :pnaz, type: String
  field :knaz, type: String
  field :status, type: Integer
  field :k_form, type: Integer
  field :n_form, type: String
  field :edrpou_v, type: String
  field :naz_v, type: String
  field :k_ter, type: String
  field :adp, type: String
  field :mtk, type: String
  field :tel1, type: String
  field :tel2, type: String


  before_save :encode_fields, :find_town
  belongs_to :town, class_name: 'Town',index: true
  scope :by_town, -> (town) { where(town: town) }
  scope :by_koatuu, -> (koatuu, symbol_quantity = koatuu[2..10].eql?('00000000') ? 2 : 5) { where(k_ter: /^#{(koatuu.to_s.strip)[0..symbol_quantity-1]}/i) }
  scope :search_part_title, -> (part) {any_of({pnaz: /#{part}/i}, {edrpou: /^#{part}/i})}


  def encode_fields
    attr_array = [pnaz, knaz, n_form, naz_v, adp]
    attr_array.each do |attr|
      #binding.pry
      incorrect_characters(attr)
    end

  end


  def find_town
    k_ter_tmp = k_ter
    if k_form == K_FORM_STATE_POWER
      str = k_ter[5..10]
      if(str != "00000")
        k_ter_tmp = k_ter.gsub str, "00000"
      end
    end
    town = Town.where(:koatuu => k_ter_tmp).first
    unless town.nil?
      self.town = town
    end
  end

  def incorrect_characters text
    text.gsub! "Ў", "І"
    text.gsub! "ў", "і"
    text.gsub! "∙", "ї"
  end


  def self.to_csv payments
    CSV.generate(headers: true, col_sep: "\t") do |csv|
      csv << [
          I18n.t('modules.classifier.search_e_data.sum'),
          I18n.t('modules.classifier.search_e_data.payer'),
          I18n.t('modules.classifier.search_e_data.recipt'),
          I18n.t('modules.classifier.search_e_data.purpose'),
          I18n.t('modules.classifier.search_e_data.date')
      ]
      payments.each do |payment|
        csv << [
            payment['amount'],
            payment['payer_name'],
            payment['recipt_name'] + " " + payment['recipt_edrpou'],
            payment['payment_details'],
            payment['trans_date'].split('T')[0]
        ]
      end
    end
  end

  def fill_params attributes, types
      if types.include? attributes["K_FORM"]
        self.sk_ter = attributes["SK_TER"]
        self.kvk = attributes["KVK"]
        self.rkrk = attributes["RKRK"]
        self.edrpou = attributes["EDRPOU"]
        self.pnaz = attributes["PNAZ"]
        self.knaz = attributes["KNAZ"]
        self.status = attributes["STATUS"]
        self.k_form = attributes["K_FORM"]
        self.n_form = attributes["N_FORM"]
        self.edrpou_v = attributes["EDRPOU_V"]
        self.naz_v = attributes["NAZ_V"]
        self.k_ter = attributes["K_TER"]
        self.adp = attributes["ADP"]
        self.mtk = attributes["MTK"]
        self.tel1 = attributes["TEL1"]
        self.tel2 = attributes["TEL2"]
        self.save
        true
      else false
      end

  end 



end
