require 'httparty'

require_relative 'dispatch/config'
require_relative 'dispatch/delivery'
require_relative 'dispatch/errors'
require_relative 'dispatch/response'
require_relative 'dispatch/version'
require_relative 'dispatch/engine' if defined?(Rails)

#
# Dispatch Client
#
# Dispatch messages where they need to be
#
module Dispatch
  SMS_PARAMS = %i[to body test validate].freeze

  EMAIL_PARAMS = %i[
    html
    text
    body
    subject
    from
    from_name
    from_email
    to
    headers
    important
    track_clicks
    track_opens
    auto_text
    auto_html
    inline_css
    url_strip_qs
    preserve_recipients
    view_content_link
    bcc_address
    tracking_domain
    signing_domain
    return_path_domain
    merge
    merge_language
    global_merge_vars
    merge_vars
    tags
    subaccount
    google_analytics_domains
    google_analytics_campaign
    metadata
    recipient_metadata
    attachments
    images
    reply_to
    test
    data
    validate
    notifiable_id
    notifiable_type
  ].freeze

  @config = Config.new

  include HTTParty
  headers 'Content-Type' => 'application/json'

  class << self
    def config
      yield(@config) if block_given?
      @config
    end

    def status
      get(@config[:endpoint]).parsed_response['status']
    end

    def find(guid)
      Delivery.parse get("#{@config[:endpoint]}/deliveries/#{guid}.json")
    end

    def sms(params)
      validate_params(SMS_PARAMS, params)
      validate_required(params, :to, :body)
      validate_matches(/^[+0-9\(\)\s\.]{10,}$/, 'phone number', params[:to])

      return true if params[:validate]

      deliver(params.merge(tech: 'sms'))
    end

    def email(params)
      validate_params(EMAIL_PARAMS, params)
      validate_required(params, :to,
                        body: -> { blank? params[:attachments] })

      return true if params[:validate]

      deliver(params.merge(tech: 'email'))
    end

    def deliver(options)
      validate_required(@config, :endpoint, :key)

      response = post("#{@config[:endpoint]}/deliveries.json",
                      body: { key: @config[:key], delivery: options }.to_json)

      Delivery.parse(response)
    end

    private

    def validate_params(source, params)
      params.each_pair do |key, _value|
        next if source.include?(key)
        raise UnknownArgumentError, key
      end
    end

    # validate that the provided required keys are included
    # if a lambda is provided, the key will only be required if the lambda
    # evaluates as true
    def validate_required(params, *keys)
      keys.each do |key|
        if key.is_a?(Hash)
          key.each_pair do |nkey, proc|
            value = params[nkey]
            invalid = blank?(value) && proc.call
            raise EmptyArgumentError.new(nkey, value) if invalid
          end
        else
          value = params[key]
          invalid = blank?(value)
          raise EmptyArgumentError.new(key, value) if invalid
        end
      end
    end

    def validate_matches(pattern, name, *values)
      values.flatten.each do |value|
        next if value.match?(pattern)
        raise InvalidArgumentError.new(name, value)
      end
    end

    def blank?(value)
      value.nil? || value.empty?
    end
  end
end
