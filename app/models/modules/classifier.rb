class Modules::Classifier
  include Mongoid::Document
  #include Mongoid::Timestamps
  K_FORM_STATE_POWER = 410
  K_FORM_LOCAL_GOVERNMENT = 420
  K_FORM_STATE_ORGANIZATION = 425
  K_FORM_COMMUNAL_ORGANIZATION = 430
  K_FORM_COMMUNAL_ORGANIZATION = 440

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
  scope :by_koatuu, -> (koatuu, symbol_quantity=5) { where(k_ter: /^#{(koatuu.to_s.strip)[0..symbol_quantity-1]}/i) }
  def encode_fields
    attr_array = [pnaz, knaz, n_form, naz_v, adp]
    attr_array.each do |attr|
      #binding.pry
      incorrect_characters(attr)
    end

  end

  def self.to_xls(payments)
    require 'rubyXL'
    this_calendar = Calendar.find(id)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Calendar'
    i=0
    this_calendar.attributes.each do |attr_name, attr_value|
      if(attr_name != 'events')
        worksheet.add_cell(0, i, attr_name)
        worksheet.add_cell(1, i, attr_value)
      end
      i=i+1
    end

    worksheet = workbook.add_worksheet('Events')
    events = this_calendar.events
    # j=0
    event_attributes = ["_id", "holder", "title", "icon", "description",  "starts_at", "ends_at", "all_day", "text_color", "color"]
    # event_attributes.each do |attribute_name|
    #   worksheet.add_cell(0, j, attribute_name)
    #   j=j+1
    # end
    i = 0
    # event_attributes = ["title"]
    events.each do |event|
      j=0
      event_attributes.each do |attribute_name|
        if(i==0)
          worksheet.add_cell(i, j, attribute_name)
        else
          worksheet.add_cell(i, j, event.send(attribute_name))
        end
        j=j+1
      end
      i=i+1
    end
    workbook.stream.read

  end


  def find_town
    k_ter_tmp = k_ter
    #binding.pry
    if k_form == K_FORM_STATE_POWER
      #binding.pry

      str = k_ter[5..10]

      if(str != "00000")
        k_ter_tmp = k_ter.gsub str, "00000"
        #binding.pry
      end
    end
    town = Town.where(:koatuu => k_ter_tmp).first
    unless town.nil?
      self.town = town
    end
    #binding.pry
  end

  def incorrect_characters text
    text.gsub! "Ў", "І"
    text.gsub! "ў", "і"
    text.gsub! "∙", "ї"
  end


  def self.to_csv
    attributes = %w{edrpou pnaz k_ter}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |classf|
        csv << attributes.map{ |attr| classf.send(attr) }
      end
    end
  end

  def fill_params attributes

      #binding.pry
      if [K_FORM_STATE_POWER, K_FORM_LOCAL_GOVERNMENT, K_FORM_STATE_ORGANIZATION, K_FORM_COMMUNAL_ORGANIZATION].include? attributes["K_FORM"]
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
        #binding.pry
        self.save
        true
      else false
      end

  end

  def types
    [K_FORM_STATE_POWER, K_FORM_LOCAL_GOVERNMENT, K_FORM_STATE_ORGANIZATION, K_FORM_COMMUNAL_ORGANIZATION,  K_FORM_COMMUNAL_ORGANIZATION];
  end


end