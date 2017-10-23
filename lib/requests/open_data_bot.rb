module Requests
  class OpenDataBot
    attr_reader :warnings
    def initialize(attributes = {})
      @warnings = attributes['warnings']
    end

    def has_decisions?
      @warnings && @warnings[0].key?('decisions')
    end

    def decisions
      @warnings[0]['decisions']
    end
  end
end