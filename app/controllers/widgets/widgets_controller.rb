class Widgets::WidgetsController < ApplicationController
  after_action :allow_iframe
  layout 'visify'

private
  def allow_iframe
    response.headers['x-frame-options'] = 'ALLOWALL'
  end
end
