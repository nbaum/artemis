Application.routes.draw do
  root 'site#root'
  get 'errors/:status' => 'site#error', status: /404|500/
end
