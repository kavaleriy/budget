# simple logic for document and link models
module Documentation
  extend ActiveSupport::Concern

  included do
    def check_access(user)
      user.is_admin? || self.town.eql?(user.town_model)
    end
  end
end