module ControllerCaching
  extend ActiveSupport::Concern

  def get_controller_action_key
    "#{controller_name} #{action_name}"
  end

  def use_cache key = nil
    Rails.cache.fetch( key.nil? ? cache_key : key, :expires_in => Rails.env.development? ? 10.seconds : 12.hours) do
      yield
    end
  end

  private
    def cache_key
      par = params.sort.flatten.join("_obj")
      Digest::SHA1.hexdigest("#{get_controller_action_key}#{par}")
    end

end
