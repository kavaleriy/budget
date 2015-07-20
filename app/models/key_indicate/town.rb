class KeyIndicate::Town
  include Mongoid::Document

  before_save :generate_title

  field :title, type: String

  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy

  private

  def generate_title
    self.title = current_user.town
  end

end
