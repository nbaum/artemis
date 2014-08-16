module Artemis

  class Ship < Actor

    key :index, :consoles
    
    def initialize (index)
      self.index = index
      self.consoles = [0] * 10
    end

  end

end

#  + Math::PI) / Math::PI * 720
