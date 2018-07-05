module Dispatch
  Config = Struct.new(:app, :endpoint, :controller, :key) do
    def slice(*keys)
      keys.map { |k| [k, send(k)] }.to_h
    end
  end
end
