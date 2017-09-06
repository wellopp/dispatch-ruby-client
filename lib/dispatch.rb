require 'httparty'

require_relative 'dispatch/config'
require_relative 'dispatch/delivery'
require_relative 'dispatch/errors'
require_relative 'dispatch/version'

module Dispatch
  @config = Config.new

  def self.config
    yield(@config) if block_given?
    @config
  end

  def self.status
    HTTParty.get("#{@config[:endpoint]}")
  end

  def self.find(guid)
    Delivery.parse HTTParty.get("#{@config[:endpoint]}/deliveries/#{guid}.json")
  end

  def self.sms(to:, body:, test: false)
    raise EmptyArgumentError.new(:to, to) if to.nil? || to.empty?
    raise EmptyArgumentError.new(:body, body) if body.nil? || body.empty?

    if to.is_a?(Array)
      to.each do |t|
        raise InvalidArgumentError.new(:"phone number", t) if t.match?(/[^+0-9\(\)\s]/)
      end
    elsif to.match?(/[^+0-9\(\)\s]/)
      raise InvalidArgumentError.new(:"phone number", to)
    end

    deliver(to: { phone_number: to }, body: body, test: test)
  end

  def self.email(to:, from: nil, body: nil, attachments: nil, data: nil)
    raise EmptyArgumentError.new(:to, to) if to.nil? || to.empty?
    if (body.nil? || body.empty?) && (attachments.nil? || attachments.empty?)
      raise EmptyArgumentError.new(:body, body)
    end

    if (data.nil? || data.empty?) && !(body.nil? || body.empty?)
      raise EmptyArgumentError.new(:data, data)
    end

    deliver(to: to, from: from, body: body, attachments: attachments, data: data)
  end

  def self.deliver(options)
    app = @config[:app]
    endpoint = @config[:endpoint]

    raise EmptyArgumentError.new(:App, app) if app.nil? || app.empty?
    raise EmptyArgumentError.new(:Endpoint, endpoint) if endpoint.nil? || endpoint.empty?

    params = { delivery: options.merge(app: app) }
    puts params.inspect

    response = HTTParty.post("#{endpoint}/deliveries.json",
                             body: params.to_json,
                             headers: { 'Content-Type' => 'application/json' })

    Delivery.parse(response)
  end
end

Dispatch.config do |c|
  c.app = :messenger_qa
  c.endpoint = 'http://localhost:3000'
end
