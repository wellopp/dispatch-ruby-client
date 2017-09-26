module Dispatch
  class ResponsesController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_dispatch_request!

    private

    def verify_dispatch_request!
      valid = (request_signature == request.headers['X-Dispatch-Signature'])
      render(nothing: true, status: 403) unless valid
    end

    def request_signature
      payload = request.url
      payload << request.request_parameters.sort.join
      Rails.logger.info payload
      Base64.strict_encode64(
        OpenSSL::HMAC.digest('sha1', Dispatch.config.key, payload)
      )
    end
  end
end
