class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action do
    @title = "Boilerplate"
  end
end
