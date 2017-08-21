module Dispatch
  class EmptyArgumentError < ArgumentError
    def initialize(attr, value)
      super "#{attr} cannot be empty, but #{value.inspect} was provided"
    end
  end

  class InvalidArgumentError < ArgumentError
    def initialize(attr, value)
      super "The #{attr} you provided, #{value.inspect}, is not valid"
    end
  end
end
