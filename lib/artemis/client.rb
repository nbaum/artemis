module Artemis

  class Client

    def initialize ()
      @io = @socket = TCPSocket.new("127.0.0.1", 2010)
      @codec = Artemis::Codec.new(@socket)
      singleton_class.__send__ :include, Encoder::InstanceMethods
      game
    end

    def close
      @socket.close
    end

    def game
      @game ||= Game.new
    end

    def dispatch (pdu)
      return if pdu[:type].nil?
      begin
        p pdu if pdu[:type] == :jump_end
        __send__("on_#{type = pdu.delete(:type)}", pdu)
      rescue => e
        puts "#{type}: #{e.message}"
        puts e.backtrace.join("\n")
        puts
      end
    end

    def run ()
      while pdu = @codec.next
        dispatch(pdu)
      end
    end

    def on_jump_end (_)
      game.jumping = false
      ready
    end

    def on_welcome (message: nil)
      game.welcome = message
    end

    def on_version (version: nil)
      game.version = version
    end

    def on_game_start (_)
      game.running = true
    end

    def on_game_over (_)
      @game = nil
      game
    end

    def on_comms_incoming (sender: nil, message: nil, priority: nil)
      game.messages ||= []
      game.messages << [sender, message]
    end

    def on_game_over_reason (reason: nil)
    end

    def on_console_status (ship: nil, statuses: nil)
      game[ship - 1].consoles.replace statuses
    end

    def on_all_ship_settings (ships: nil)
      ships.each.with_index do |ship, i|
        game[i].merge!(ship)
      end
    end

    def on_object_update (updates: nil)
      updates.each do |update|
        dispatch(update)
      end
    end

    def on_eng_player_update (id: nil, **hash)
      sys = player[:systems] ||= {}
      hash.each do |system, state|
        sys = player[:systems][system] ||= {
          heat: 0,
          energy: 0,
          coolant: 0
        }
        sys.merge! state
      end
    end

    def object_update (id, type, **hash)
      actor = game.actors[id] ||= type.new
      actor.merge! hash
      actor
    end

    def on_base (id: nil, **hash)
      object_update id, Base, **hash
      #base[:ffi] = player[:side] == base[:side] ? 0 : 1
    end

    def on_player_update (id: nil, **hash)
      if num = hash[:ship_number]
        object_update num - 1, Ship, hash
      end
      #p hash
      #game.player = game.actors[id] ||= Ship.new
      #game.player.update **hash
    end

    def on_anomaly_update (id: nil, **hash)
      object_update id, :anomaly, **hash
    end

    def on_black_hole_update (id: nil, **hash)
      object_update id, :black_hole, **hash
    end

    def on_monster_update (id: nil, **hash)
      object_update id, :monster, **hash
    end

    def on_mine_update (id: nil, **hash)
      object_update id, :mine, **hash
    end

    def on_asteroid_update (id: nil, **hash)
      object_update id, :asteroid, **hash
    end

    def on_nebula_update (id: nil, **hash)
      object_update id, :nebula, **hash
    end

    def on_npc_update (id: nil, **hash)
      npc = object_update id, NPC, **hash
      npc[:shield_strengths] = {
        A: npc[:shield_strength_a], 
        B: npc[:shield_strength_b], 
        C: npc[:shield_strength_c], 
        D: npc[:shield_strength_d], 
        E: npc[:shield_strength_e], 
      }
      npc[:shield_weakness] = npc[:shield_strengths].to_a.sort_by{|k,v|v}[0][0]
    end

    def on_whale_update (id: nil, **hash)
      object_update id, :whale, **hash
    end

    def on_intel (target: nil, intel: nil)
      game[target].intel = intel
    end

    def on_weap_player_update (h)
      #p h
    end

    def on_beam_fired (h)
      # pew pew pew!
    end

    def on_keep_alive (_)
    end

    def on_eng_grid_update (h)
      p h
    end

    def on_skybox (skybox: nil)
      game.venue = skybox
    end

    def on_difficulty (difficulty: nil, game_type: nil)
      game.difficulty = difficulty
      game.game_type = game_type
    end

    def on_key_capture (h)
      p h
    end

    #def on_set_console (console: nil, state: nil)
    #  games.ships
    #end

  end

end
