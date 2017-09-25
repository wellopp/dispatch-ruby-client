module Dispatch
  class Engine < ::Rails::Engine
    isolate_namespace Dispatch
  end
end

require_relative '../../config/routes.rb'
