class Modules::BudgetNews
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  require 'carrierwave/mongoid'

  scope :get_last_news, ->(count) {order("news_date DESC").limit(count)}

  # before_save :set_date
  before_save :publish_news

  validates :title,:news_text, presence: true
  validates :link, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/,
                             message: I18n.t('activerecord.attributes.invalid.link') }, allow_blank: true

  mount_uploader :img, BudgetNewsImageUploader
  field :title, type: String
  field :news_text, type: String
  field :link, type: String
  field :published, type: Boolean
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
    # rewrite time created_at by news_date if created_at nil
    self.created_at = self.news_date if self.created_at.nil?
    # rewrite time news_date by created_at if news_date nil
    self.news_date = self.created_at if self.news_date.nil?

    self.news_date.strftime "%Y-%m-%d %H:%M:%S"
  end

  private
    mount_uploader :img, BudgetNewsImageUploader
    skip_callback :update, :before, :store_previous_model_for_img

  def publish_news
    # init published field by default as false
    self.published = false if self.published.nil?
  end

  # def set_date
  #   utc_offset = +2
  #   zone = ActiveSupport::TimeZone[utc_offset].name
  #   Time.zone = zone
  #   self.news_date = Time.zone.now
  # end

end
