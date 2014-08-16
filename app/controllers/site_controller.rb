require 'socket'

class VolatileHash < Hash

  def initialize (hash = nil)
    merge! hash if hash
  end

  def [] (key)
    delete(key)
  end

end

class SiteController < ApplicationController

  def root
    #logout
    client
    #until client.ship[:name]
    #  sleep 0.1
    #end
    render layout: nil if request.xhr?
  end

  def logout
    client.close
    clients.delete(client)
    session.clear
    #client
    #render text: "ok"
  end

  def error
    @exception = env["action_dispatch.exception"]
    render "site/errors/#{params[:status] || 500}"
  end

end
