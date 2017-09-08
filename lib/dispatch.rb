require 'httparty'

require_relative 'dispatch/config'
require_relative 'dispatch/delivery'
require_relative 'dispatch/errors'
require_relative 'dispatch/version'

#
# Dispatch Client
#
# Dispatch messages where they need to be
#
module Dispatch
  SMS_PARAMS = %i(to body test).freeze

  EMAIL_PARAMS = %i(
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
  ).freeze

  @config = Config.new

  class << self
    def config
      yield(@config) if block_given?
      @config
    end

    def status
      HTTParty.get(@config[:endpoint]).parsed_response['status']
    end

    def find(guid)
      Delivery.parse HTTParty.get("#{@config[:endpoint]}/deliveries/#{guid}.json")
    end

    def sms(params)
      validate_params(SMS_PARAMS, params)
      validate_required(params, :to, :body)
      validate_matches(/[^+0-9\(\)\s]/, 'phone number', to)

      deliver(params.merge(tech: 'sms'))
    end

    def email(params)
      validate_params(EMAIL_PARAMS, params)
      validate_required(params, :to,
                        body: -> { params[:attachments].nil? || params[:attachments].empty? })

      deliver(params.merge(tech: 'email'))
    end

    def deliver(options)
      validate_required(@config, :app, :endpoint)

      params = { delivery: options.compact.merge(app: app) }

      response = HTTParty.post("#{endpoint}/deliveries.json",
                               body: params.to_json,
                               headers: { 'Content-Type' => 'application/json' })

      Delivery.parse(response)
    end

    private

    def validate_params(source, params)
      params.each_pair do |key, _value|
        next if source.include?(key)
        raise ::ArgumentError, "unknown parameter #{key}"
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
            invalid = (value.nil? || value.empty?) && proc.call
            raise EmptyArgumentError.new(nkey, value) if invalid
          end
        else
          value = params[key]
          invalid = value.nil? || value.empty?
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
  end
end
