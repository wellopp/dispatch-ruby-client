module Dispatch
  # Base class for handing incoming Dispatch response requests.
  # Extend your class from this class and incoming requests will be validated
  # for you.
  class ResponsesController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_dispatch_request!
    before_action :set_response

    private

    def set_response
      @response = Dispatch::Response.new(params[:response])
    end

    def verify_dispatch_request!
      valid = (request_signature == request.headers['X-Dispatch-Signature'])
      render(nothing: true, status: 403) unless valid
    end

    def request_signature
      payload = [request.url, request.raw_post].join
      Base64.strict_encode64(
        OpenSSL::HMAC.digest('sha1', Dispatch.config.key, payload)
      )
    end
  end
end
