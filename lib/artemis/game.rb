module Artemis

  class Game

    attr_accessor :ship, :actors, :welcome, :version, :ready

    def initialize
      self.ship = 0
      self.actors = {}
      8.times do |i|
        actors[i] = Ship.new(i)
      end
    end

    def ships
      8.times.map do |i|
        actors[i]
      end
    end

    def player
      actors[ship]
    end

    def [] (id)
      actors[id]
    end

    def []= (id, value)
      actors[id] = value
    end

  end

end
