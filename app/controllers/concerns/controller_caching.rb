module ControllerCaching
  extend ActiveSupport::Concern

  def use_cache key = nil
    Rails.cache.fetch( key.nil? ? cache_key : key, :expires_in => Rails.env.development? ? 10.minutes : 12.hours) do
      yield
    end
  end

  private
    def cache_key
      Digest::SHA1.hexdigest(params.sort.flatten.join("_object"))
    end

end
