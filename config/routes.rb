Application.routes.draw do
  root 'site#root'
end

Application.config.exceptions_app.draw do
  get '404' => 'errors#not_found'
  get '500' => 'errors#server_error'
end
