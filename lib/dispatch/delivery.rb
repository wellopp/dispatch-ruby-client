module Dispatch
  # Minor abstraction to wrap JSON responses from Dispatch
  class Delivery
    attr_reader :data

    def self.parse(httparty_response)
      case httparty_response.code
      when 201
        data = JSON.parse(httparty_response.body)
        data['deliveries'].map { |d| Delivery.new(d) }
      when 200
        Delivery.new(httparty_response.parsed_response)
      when 404
        Delivery.new
      else
        [Delivery.new(httparty_response)]
      end
    end

    def initialize(data = {})
      @data = data
    end

    def found?
      !id.nil?
    end

    def created?
      !id.nil?
    end

    def method_missing(method, *_args, &_block)
      data[method.to_s]
    end
  end
end
