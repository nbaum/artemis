class Hash

  def merge_keys! (hash, *keys)
    keys.each do |key|
      self[key] = hash[key] if hash.has_key?(key)
    end
    self
  end

  def merge_keys (hash, *keys)
    dup.merge_keys!(hash, *keys)
  end

end

class ApiController < ApplicationController

  def invoke
    __send__(params.delete(:api))
    redirect_to :back unless performed?
  end

  def data
    render json: { objects: client.game.actors, player: client.player }
  end

  def reset
    client.close
    clients.delete(client)
    session.clear
    client
    sleep 1
  end

  def set_energy ()
    if params[:system]
      client.set_energy(params[:system].to_i, params[:energy].to_f / 300.0)
    else
      8.times do |i|
        client.set_energy(i, params[:energy].to_f / 300.0)
        client.set_coolant(i, 120)
      end
    end
  end

  def scan
    client.scan(params[:id].to_i)
  end

  def target
    client.target(params[:id].to_i)
    client.player[:weapons_target] = params[:id].to_i
    if t = client.game.actors[params[:id].to_i]
      if f = t[:shield_weakness]
        client.set_beam_freq("ABCDE".index(f.to_s))
      end
    end
  end

  def jump
    if id = params[:id]
      params[:x] = client.game.actors[id.to_i][:x]
      params[:z] = client.game.actors[id.to_i][:z]
    end
    if params[:x] and params[:z]
      dx = client.player[:x] - params[:x].to_f
      dy = client.player[:z] - params[:z].to_f
      params[:distance] = ((dx ** 2 + dy ** 2) ** 0.5 - 10) / 50000
      params[:bearing] = Math.atan2(dx, dy) / (Math::PI * 2)
      params[:bearing] = 1 + params[:bearing] if params[:bearing] < 0
      p [params[:bearing], params[:distance]]
    end
    if params[:bearing] and params[:distance]
      client.jump(params[:bearing].to_f, params[:distance].to_f)
      game.jumping = true
      Thread.new do
        sleep 10
        game.jumping = false
      end
    end
  end

  def ready
    client.ready()
    client.game.ready = true
  end

  def toggle_reverse
    player[:reverse] = 1 - player[:reverse]
    client.toggle_reverse
  end

  def set_impulse
    speed = params[:impulse].to_f / 100
    if speed < 0
      toggle_reverse if player[:reverse] == 0
      client.set_impulse(-speed)
    else
      toggle_reverse if player[:reverse] == 1
      client.set_impulse(speed)
    end
    player[:impulse] = speed.abs
  end

  def set_warp
    factor = params[:warp].to_i
    client.set_warp(factor)
    player[:warp] = factor
  end

  def set_ship
    client.set_ship(params[:index].to_i)
    game.ship = params[:index].to_i
  end
 
  def claim_console
    player.consoles[params[:index].to_i] = 1
  end

  def unclaim_console
    player.consoles[params[:index].to_i] = 0
  end

  def set_ship_settings
    ship = client.ship.merge_keys!(params, :drive_type, :ship_type, :name)
    ship[:drive_type] = ship[:drive_type].to_i
    ship[:ship_type] = ship[:ship_type].to_i
    client.set_ship_settings(ship[:drive_type], ship[:ship_type],
                             ship[:name])
  end

  private
  
  def game
    client.game
  end

  def player
    game.player
  end

end
