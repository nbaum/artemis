module Artemis

  class Actor < SmartHash

    key :x, :y, :z
    key :velocity, :y_velocity
    key :heading, :pitch, :roll
    key :reverse
    key :rudder, :impulse, :warp
    key :energy
    key :top_speed, :turn_rate
    key :auto_beams, :shields, :red_alert
    key :weapons_target, :docking_target, :scan_target,
        :science_target, :captain_target
    key :name
    key :fore_shields, :fore_shields_max
    key :aft_shields, :aft_shields_max
    key :coolant
    key :beam_frequency
    key :drive_type
    key :ship_type
    key :faction

    def initialize ()
      @consoles = [0] * 10
    end

  end

end

#  + Math::PI) / Math::PI * 720
