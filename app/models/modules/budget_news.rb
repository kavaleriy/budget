class Modules::BudgetNews
  include Mongoid::Document
  include Rails.application.routes.url_helpers
  require 'carrierwave/mongoid'

  before_save :set_date

  scope :get_last_news , -> (count) {order(news_date: :desc).limit(count)}

  validates :title,:news_text,:img, presence: true
  validates :link, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/,
                             message: I18n.t('activerecord.attributes.invalid.link') }, allow_blank: true

  mount_uploader :img, BudgetNewsImageUploader
  # include Mongoid::Timestamps
  field :title, type: String
  field :news_text, type: String
  field :link, type: String
  field :news_date, type: Time

  def delete_image_file!
    self.remove_img!;
  end

  def news_preview
    news_text[0..200] + '...' ;
  end

  def get_link
    if self.link.empty?
      self.link = modules_budget_news_path(self)
    end
    self.link
  end

  def get_date
    self.news_date.strftime "%Y-%m-%d %H:%M:%S"
  end

  private
    mount_uploader :img, BudgetNewsImageUploader
    skip_callback :update, :before, :store_previous_model_for_img

  def set_date
    utc_offset = +2
    zone = ActiveSupport::TimeZone[utc_offset].name
    Time.zone = zone
    self.news_date = Time.zone.now
  end

end
