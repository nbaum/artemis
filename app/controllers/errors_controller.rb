class ErrorsController < ApplicationController
  protect_from_forgery with: :null_session
  layout 'errors'
  
  before_filter do
    render status: action.to_i
  end
  
end
