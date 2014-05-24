Application.routes.draw do
  root 'site#root'
end

Application.error_routes.draw do
  get '404' => 'errors'
  get '500' => 'errors'
end
