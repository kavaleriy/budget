class Widgets::WidgetsController < ApplicationController
  after_filter :allow_iframe
  layout 'visify'

private
  def allow_iframe
    response.headers['x-frame-options'] = 'ALLOWALL'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  end
end
