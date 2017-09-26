module Dispatch
  class Response
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def method_missing(method, *_args, &_block)
      data[method.to_s]
    end
  end
end
