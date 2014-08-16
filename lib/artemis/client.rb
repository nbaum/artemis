module Artemis

  class Console
    attr_accessor :manned
  end

  class NPC
    attr_accessor :consoles, :drive_type, :ship_type, :name, :energy,
                  :rudder, :x, :y, :z, :pitch, :roll, :heading,
                  :damage1
    def initialize
      @consoles = Hash.new do |h, k|
        h[k] = Console.new
      end
    end
  end

  class Ship < NPC
    attr_accessor :scan_progress
  end

  class Game
    attr_accessor :ships, :npcs, :whales, :version
    def initialize
      @ships = Hash.new do |h, k|
        h[k] = Ship.new
      end
      @npcs = Hash.new do |h, k|
        h[k] = NPC.new
      end
      @whales = Hash.new do |h, k|
        h[k] = NPC.new
      end
    end
  end

  class Client

    def initialize (codec)
      @codec = codec
    end

    def game ()
      @game ||= Game.new
    end

    def dispatch (pdu)
      begin
        __send__("on_#{type = pdu.delete(:type)}", pdu)
      rescue NoMethodError => e
        raise e
      end
    end

    def run ()
      while pdu = @codec.next
        dispatch(pdu)
      end
    end

    def on_welcome (message: nil)
    end

    def on_version (version: nil)
      game.version = version
    end

    def on_console_status (ship: nil, status: nil)
      status.each do |name, state|
        game.ships[ship].consoles[name].manned = state == 0 ? false : true
      end
    end

    def on_all_ship_settings (ships: nil)
      ships.each.with_index do |ship, i|
        s = game.ships[i]
        s.drive_type = ship[:drive_type]
        s.ship_type = ship[:ship_type]
        s.name = ship[:name]
      end
    end

    def on_object_update (updates: nil)
      updates.each do |update|
        dispatch(update)
      end
    end

    def on_main_player_update (id: nil, **hash)
      hash.each do |key, value|
        game.ships[id].__send__("#{key}=", value)
      end
    end

    def on_npc_update (id: nil, **hash)
      hash.each do |key, value|
        game.npcs[id].__send__("#{key}=", value)
      end
    end

    def on_whale_update (id: nil, **hash)
      hash.each do |key, value|
        game.whales[id].__send__("#{key}=", value)
      end
    end

    def on_keep_alive (_)
    end

    #def on_set_console (console: nil, state: nil)
    #  games.ships
    #end

  end

end
