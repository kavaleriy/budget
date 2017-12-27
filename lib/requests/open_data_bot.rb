# frozen_string_literal: true

# not used
# previously used for api queries open_data_bot
module Requests
  class OpenDataBot
    attr_reader :warnings
    def initialize(attributes = {})
      @warnings = attributes['warnings']
    end

    def decisions?
      @warnings && @warnings[0].key?('decisions')
    end

    def decisions
      @warnings[0]['decisions']
    end
  end
end
