Dispatch::Engine.routes.draw do
  if Dispatch.config.controller
    post 'responses', to: "#{Dispatch.config.controller}#create"
  end
end
