Application.routes.draw do
  root 'site#root'
  get 'omni' => 'site#omni'
  get 'logout' => 'site#logout'
  get ':ship/engineering' => 'site#engineering'
  get 'errors/:status' => 'site#error', status: /404|500/
  match '1/:api' => 'api#invoke', via: %i"get post", as: :api
end
