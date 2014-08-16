class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery

  private

  def client
    if i = session[:client]
      if c = clients[i]
        return c
      end
    end
    clients[session[:client] = make_client]
  end

  helper_method :client

  def clients
    $clients ||= []
  end

  def make_client
    client = Artemis::Client.new
    Thread.new do
      client.run
    end
    #client.set_ship(0)
    #client.ready2
    $clients << client
    $clients.length - 1
  end

end
