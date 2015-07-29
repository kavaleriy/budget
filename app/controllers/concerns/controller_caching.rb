module ControllerCaching
  extend ActiveSupport::Concern

  def use_cache
    Rails.cache.fetch( cache_key, :expires_in => Rails.env.development? ? 1.minute : 12.hours) do
      yield
    end
  end

  private
    def cache_key
      Digest::SHA1.hexdigest(params.sort.flatten.join("_object"))
    end

end
