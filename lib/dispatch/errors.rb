module Dispatch
  class ArgumentError < ::ArgumentError
    attr_reader :attribute, :value
    def initialize(attr, value, msg)
      super(msg)
      @attribute = attr
      @value = value
    end
  end

  class EmptyArgumentError < ArgumentError
    def initialize(attr, value)
      super attr, value, "#{attr} cannot be empty, but #{value.inspect} was provided"
    end
  end

  class InvalidArgumentError < ArgumentError
    def initialize(attr, value)
      super attr, value, "The #{attr} you provided, #{value.inspect}, is not valid"
    end
  end
end
