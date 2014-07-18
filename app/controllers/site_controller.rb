class SiteController < ApplicationController

  def root
    render :sample
  end

  def error
    @fake = env["action_dispatch.exception"].nil?
    render "site/errors/#{params[:status]}"
  end

end
