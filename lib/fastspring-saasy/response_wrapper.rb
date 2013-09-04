require 'active_support/core_ext/module/delegation'

module FastSpring
  class ResponseWrapper
    attr_reader :raw
    delegate :success?, :code, :message, :body, to: :raw

    def initialize(response)
      @raw = response
    end

    def location
      @raw.headers['location']
    end

    def reference
      location.split('/').last unless location.nil?
    end

  end
end
