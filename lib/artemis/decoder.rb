require 'stringio'

module Artemis

  module Decoder

    def self.decode_subtypes (type, meth)
      type &&= type.to_s(16)
      define_method "unpack_#{type}" do |data|
        io = StringIO.new(data)
        io.extend Types
        subtype = io.__send__(meth).to_s(16)
        __send__("unpack_#{type}_#{subtype}", io)
      end
    end

    def self.decode (name, type, subtypes = [], &block)
      type &&= type.to_s(16)
      subtypes = [subtypes].flatten
      if !subtypes.empty?
        subtypes.each do |subtype|
          subtype &&= subtype.to_s(16)
          define_method "unpack_#{type}_#{subtype}" do |io|
            {type: name}.tap{|h|instance_exec(io, h, &block)}
          end
        end
      else
        define_method "unpack_#{type}" do |data|
          io = StringIO.new(data)
          io.extend Types
          h = {type: name}.tap{|h|instance_exec(io, h, &block)}
          #h[:rest] = io.read
          #h.delete(:rest) if h[:rest] == ""
          h
        end
      end
    end

    def unpack_subtype (type, subtype, io, h)
      type = type.to_s(16)
      subtype = subtype.to_s(16)
      __send__("unpack_#{type}_#{subtype}", io, h)
    end

    ## Server messages

    decode :beam_fired, 0xb83fd2c4 do |io, h|
      h[:id] = io.read_int
      h[:_1] = io.read_int
      h[:_2] = io.read_int
      h[:port] = io.read_int
      h[:_3] = io.read_int
      h[:_4] = io.read_int
      h[:origin] = io.read_int
      h[:target] = io.read_int
      h[:x] = io.read_float
      h[:y] = io.read_float
      h[:z] = io.read_float
      h[:manual] = io.read_int == 1
    end

    decode :comms_incoming, 0xd672c35f do |io, h|
      h[:priority] = io.read_int
      h[:sender] = io.read_string
      h[:message] = io.read_string
    end

    decode :destroy_object, 0xcc5a3e30 do |io, h|
      io.read_byte
      h[:target] = io.read_int
    end

    decode :difficulty, 0x3de66711 do |io, h|
      h[:difficulty] = io.read_int
      h[:game_type] = [:seige, :single_front, :double_front, :deep_strike, :peacetime, :border_war][io.read_int]
    end

    decode :eng_grid_update, 0x077e9f3c do |io, h|
      io.read_byte
      h[:nodes] = []
      h[:teams] = {}
      io.until_byte(0xff) do
        h[:nodes] << {
          x: io.read_byte,
          y: io.read_byte,
          z: io.read_byte,
          damage: io.read_float
        }
      end
      io.until_byte(0xfe) do
        h[:teams][io.read_byte] = {
          to_x: io.read_int,
          at_x: io.read_int,
          to_y: io.read_int,
          at_y: io.read_int,
          to_z: io.read_int,
          at_z: io.read_int,
          progress: io.read_float,
          size: io.read_int
        }
      end
    end

    decode_subtypes 0xf754c8fe, :read_int

    decode nil, 0xf754c8fe, 0x07 do |io, h|
    end

    decode :all_ship_settings, 0xf754c8fe, 0x0f do |io, h|
      h[:ships] = 8.times.map do
        {
          drive_type: io.read_int,
          ship_type: io.read_int,
          nil => io.read_int,
          name: io.read_string,
        }
      end
    end

    decode :dmx_message, 0xf754c8fe, 0x10 do |io, h|
      h[:name] = io.read_string
      h[:state] = io.read_int
    end

    decode :game_message, 0xf754c8fe, 0x0a do |io, h|
      h[:message] = io.read_string
    end

    decode :game_over, 0xf754c8fe, 0x06 do |io, h|
    end

    decode :game_over_reason, 0xf754c8fe, 0x14 do |io, h|
      h[:reason] = []
      until io.eof?
        h[:reason] << io.read_string
      end
    end

    decode :game_over_stats, 0xf754c8fe, 0x15 do |io, h|
      h[:column] = io.read_byte
      h[:stats] = {}
      while io.read_byte == 0
        value = io.read_int
        h[:stats][io.read_string] = value
      end
    end

    decode :game_start, 0xf754c8fe, 0x06 do |io, h|
      io.read_int
      io.read_int
    end

    decode :jump_start, 0xf754c8fe, 0x0c do |io, h|
    end

    decode :jump_end, 0xf754c8fe, 0x0d do |io, h|
    end

    decode :key_capture, 0xf754c8fe, 0x11 do |io, h|
      h[:capture] = io.read_byte
    end

    decode :player_ship_damage, 0xf754c8fe, 0x05 do |io, h|
      io.read_int
      io.read_float
    end

    decode :skybox, 0xf754c8fe, 0x09 do |io, h|
      h[:skybox] = io.read_int
    end

    decode :sound_effect, 0xf754c8fe, 0x03 do |io, h|
      h[:filename] = io.read_string
    end

    decode nil, 0xf754c8fe, 0x04 do |io, h|
    end

    decode nil, 0xf754c8fe, 0x08 do |io, h|
    end

    decode :incoming_audio, 0xae88e058 do |io, h|
      h[:id] = io.read_int
      h[:mode] = io.read_int
      h[:title] = io.read_string
      h[:file] = io.read_string
    end

    decode :intel, 0xee665279 do |io, h|
      h[:target] = io.read_int
      io.read_byte
      h[:intel] = io.read_string
    end

    decode :object_update, 0x80803df9 do |io, h|
      updates = []
      until io.eof?
        type = io.read_byte
        break if type == 0
        begin
          updates << self.__send__("unpack_80803df9_#{type.to_s(16)}", io)
        rescue => e
          puts e
          break
        end
      end
      throw :discard if updates.empty?
      h[:updates] = updates unless updates.empty?
      io.read(3)
    end

    decode :keep_alive, 0x80803df9, 0x00 do |io, h|
    end

    decode :drone_update, 0x80803df9, 0x10 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(2, h)
      fields.next :int
      fields.next :float, :x
      fields.next :int
      fields.next :float, :z
      fields.next :int
      fields.next :float,  :y
      fields.next :float,  :heading
      fields.next :int
    end

    decode :eng_player_update, 0x80803df9, 0x03 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(4, h)
      %i"beams torpedos sensors maneuvering impulse warp fore aft".each do |key|
        h[key] = {}
      end
      %i"beams torpedos sensors maneuvering impulse warp fore aft".each do |key|
        if v = fields.next(:float)
          h[key][:heat] = v
        end
      end
      %i"beams torpedos sensors maneuvering impulse warp fore aft".each do |key|
        if v = fields.next(:float)
          h[key][:energy] = v
        end
      end
      %i"beams torpedos sensors maneuvering impulse warp fore aft".each do |key|
        if v = fields.next(:byte)
          h[key][:coolant] = v
        end
      end
    end

    decode :generic_mesh, 0x80803df9, 0x0d do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(4, h)
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int
      fields.next :int
      fields.next :long
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :long
      fields.next :string, :name
      if fields.pop
        h[:mesh] = io.read_string
        h[:texture] = io.read_string
      end
      fields.next :int
      fields.next :short
      fields.next :byte
      fields.next :float, :red
      fields.next :float, :green
      fields.next :float, :blue
      fields.next :float, :fore_shields
      fields.next :float, :aft_shields
      fields.next :byte
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :anomaly_update, 0x80803df9, 0x07 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :byte
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :string, :name
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :monster_update, 0x80803df9, 0x0e do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :byte
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :string, :name
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :mine_update, 0x80803df9, 0x06 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :black_hole_update, 0x80803df9, 0x0b do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :asteroid_update, 0x80803df9, 0x0c do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :torpedo_update, 0x80803df9, 0x0a do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :byte
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
      fields.next :int
    end

    decode :player_update, 0x80803df9, 0x01 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(5, h)
      fields.next :int,    :weapons_target
      fields.next :float,  :impulse
      fields.next :float,  :rudder
      fields.next :float,  :top_speed
      fields.next :float,  :turn_rate
      fields.next :byte,   :auto_beams
      fields.next :byte,   :warp
      fields.next :float,  :energy
      fields.next :short,  :shields
      fields.next :int,    :ship_number
      fields.next :int,    :ship_type
      fields.next :float,  :x
      fields.next :float,  :y
      fields.next :float,  :z
      fields.next :float,  :pitch
      fields.next :float,  :roll
      fields.next :float,  :heading , &->x{(x - Math::PI) / Math::PI * 720}
      fields.next :float,  :velocity
      fields.next :short
      fields.next :string, :name
      fields.next :float,  :fore_shields
      fields.next :float,  :fore_shields_max
      fields.next :float,  :aft_shields
      fields.next :float,  :aft_shields_max
      fields.next :int,    :docking_target
      fields.next :byte,   :red_alert
      fields.next :float
      fields.next :byte,   :main_screen
      fields.next :byte,   :beam_frequency
      fields.next :byte,   :coolant
      fields.next :int,    :science_target
      fields.next :int,    :captain_target
      fields.next :byte,   :drive_type
      fields.next :int,    :scan_target
      fields.next :float,  :scan_progress
      fields.next :byte,   :reverse
      fields.next :float,  :y_velocity, &->x{-x}
      fields.next :byte,   :faction
      fields.next :int
    end

    decode :nebula_update, 0x80803df9, 0x09 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(1, h)
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :float, :red
      fields.next :float, :green
      fields.next :float, :blue
      fields.next :int
      fields.next :int
    end

    decode :npc_update, 0x80803df9, 0x04 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(6, h)
      fields.next :string, :name
      fields.next :float, :_1
      fields.next :float, :rudder
      fields.next :float, :max_impulse
      fields.next :float, :max_turn_rate
      fields.next :int, :ffi
      fields.next :int, :ship_type
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :float, :pitch
      fields.next :float, :roll
      fields.next :float, :heading
      fields.next :float, :velocity
      fields.next :byte, :surrender
      fields.next :short, :_2
      fields.next :float, :fore_shields
      fields.next :float, :fore_shields_max
      fields.next :float, :aft_shields
      fields.next :float, :aft_shields_max
      fields.next :short, :_3
      fields.next :byte, :_4
      fields.next :int, :elite_available
      fields.next :int, :elite_active
      fields.next :int, :scanned
      fields.next :int, :faction
      fields.next :int, :_5
      fields.next :byte, :side
      fields.next :byte, :_7
      fields.next :byte, :_8
      fields.next :byte, :_9
      fields.next :float, :_10
      fields.next :int, :_11
      fields.next :int, :_12
      fields.next :float, :damage0
      fields.next :float, :damage1
      fields.next :float, :damage2
      fields.next :float, :damage3
      fields.next :float, :damage4
      fields.next :float, :damage5
      fields.next :float, :damage6
      fields.next :float, :damage7
      fields.next :float, :shield_strength_a
      fields.next :float, :shield_strength_b
      fields.next :float, :shield_strength_c
      fields.next :float, :shield_strength_d
      fields.next :float, :shield_strength_e
    end

    decode :base, 0x80803df9, 0x05 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(2, h)
      fields.next :string, :name
      fields.next :float, :shields
      fields.next :float, :_1
      fields.next :int, :index
      fields.next :int, :ship_type
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :int, :_2
      fields.next :int, :_3
      fields.next :int, :_4
      fields.next :int, :_5
      fields.next :byte, :_6
      fields.next :byte, :side
    end

    decode :weap_player_update, 0x80803df9, 0x02 do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(3, h)
      fields.next :byte, :homers
      fields.next :byte, :nukes
      fields.next :byte, :mines
      fields.next :byte, :emps
      fields.next :byte
      fields.next :float, :tube_time_0
      fields.next :float, :tube_time_1
      fields.next :float, :tube_time_2
      fields.next :float, :tube_time_3
      fields.next :float, :tube_time_4
      fields.next :float, :tube_time_5
      fields.next :byte, :tube_status_0
      fields.next :byte, :tube_status_1
      fields.next :byte, :tube_status_2
      fields.next :byte, :tube_status_3
      fields.next :byte, :tube_status_4
      fields.next :byte, :tube_status_5
      fields.next :byte, :tube_contents_0
      fields.next :byte, :tube_contents_1
      fields.next :byte, :tube_contents_2
      fields.next :byte, :tube_contents_3
      fields.next :byte, :tube_contents_4
      fields.next :byte, :tube_contents_5
    end

    decode :whale_update, 0x80803df9, 0x0f do |io, h|
      h[:id] = io.read_int
      fields = io.read_bit_field(2, h)
      fields.next :string, :name
      fields.next :int
      fields.next :int
      fields.next :float, :x
      fields.next :float, :y
      fields.next :float, :z
      fields.next :float, :pitch
      fields.next :float, :roll
      fields.next :float, :heading
      fields.next :int
      fields.next :float
      fields.next :float
      fields.next :float
    end

    decode :console_status, 0x19c6e2d4 do |io, h|
      h[:ship] = io.read_int
      h[:statuses] = 10.times.map do
        io.read_byte
      end
    end

    decode :version, 0xe548e74a do |io, h|
      io.read(8)
      h[:version] = 3.times.map { io.read_int }.join(".")
    end

    decode :welcome, 0x6d04b3da do |io, h|
      h[:message] = io.read_ascii_string
    end

    ## Client messages

    decode :audio_command, 0x6aadc57f do |io, h|
      h[:id] = io.read_int
      h[:command] = io.read_int
    end

    decode :comms_outgoing, 0x574c4c4b do |io, h|
      h[:recipient_type] = io.read_int
      h[:recipient] = io.read_int
      h[:message] = io.read_int
      h[:target] = io.read_int
    end

    decode :gm_message, 0x809305a7 do |io, h|
      h[:console] = io.read_byte
      h[:sender] = io.read_string
      h[:message] = io.read_string
    end

    decode_subtypes 0x4c821d3c, :read_int

    decode :captain_select, 0x4c821d3c, 0x11 do |io, h|
      h[:target] = io.read_int
    end

    decode :climb_dive, 0x4c821d3c, 0x1b do |io, h|
      h[:direction] = io.read_int
    end

    decode :eng_set_auto_damcon, 0x4c821d3c, 0x0c do |io, h|
      h[:state] = io.read_int
    end

    decode :fire_tube, 0x4c821d3c, 0x08 do |io, h|
      h[:tube] = io.read_int
    end

    decode :helm_request_dock, 0x4c821d3c, 0x07 do |io, h|
    end

    decode :helm_set_warp, 0x4c821d3c, 0x00 do |io, h|
      h[:factor] = io.read_int
    end

    decode :helm_toggle_reverse, 0x4c821d3c, 0x18 do |io, h|
    end

    decode :keystroke, 0x4c821d3c, 0x14 do |io, h|
      h[:keycode] = io.read_int
    end

    decode :ready, 0x4c821d3c, 0x0f do |io, h|
    end

    decode :ready2, 0x4c821d3c, 0x19 do |io, h|
    end

    decode :sci_scan, 0x4c821d3c, 0x13 do |io, h|
      h[:target] = io.read_int
    end

    decode :sci_select, 0x4c821d3c, 0x10 do |io, h|
      h[:target] = io.read_int
    end

    decode :set_beam_freq, 0x4c821d3c, 0x0b do |io, h|
      h[:frequency] = io.read_int
    end

    decode :set_main_screen, 0x4c821d3c, 0x01 do |io, h|
      h[:view] = io.read_int
    end

    decode :set_ship, 0x4c821d3c, 0x0d do |io, h|
      h[:index] = io.read_int
    end

    decode :set_ship_settings, 0x4c821d3c, 0x16 do |io, h|
      h[:drive] = io.read_int
      h[:ship_type] = io.read_int
      h[:_1] = io.read_int
      h[:name] = io.read_string
    end

    decode :set_console, 0x4c821d3c, 0x0e do |io, h|
      h[:console] = io.read_int
      h[:selected] = io.read_int
    end

    decode :set_weapons_target, 0x4c821d3c, 0x02 do |io, h|
      h[:target] = io.read_int
    end

    decode :toggle_autobeams, 0x4c821d3c, 0x03 do |io, h|
    end

    decode :toggle_perspective, 0x4c821d3c, 0x1a do |io, h|
    end

    decode :toggle_red_alert, 0x4c821d3c, 0x0a do |io, h|
    end

    decode :toggle_shields, 0x4c821d3c, 0x04 do |io, h|
    end

    decode :unload_tube, 0x4c821d3c, 0x09 do |io, h|
      h[:tube] = io.read_int
    end

    decode_subtypes 0x69cc01d9, :read_int

    decode :convert_torpedo, 0x69cc01d9, 0x03 do |io, h|
      h[:direction] = io.read_float
    end

    decode :eng_send_damcon, 0x69cc01d9, 0x04 do |io, h|
      h[:team] = io.read_int
      h[:x] = io.read_int
      h[:y] = io.read_int
      h[:z] = io.read_int
    end

    decode :eng_set_coolant, 0x69cc01d9, 0x00 do |io, h|
      h[:system] = io.read_int
      h[:value] = io.read_int
    end

    decode :keep_alive, 0xf5821226 do |io, h|
    end

    decode :load_tube, 0x69cc01d9, 0x02 do |io, h|
      h[:tube] = io.read_int
      h[:ordnance] = io.read_int
    end

    decode_subtypes 0x0351a5ac, :read_int

    decode :eng_set_energy, 0x0351a5ac, 0x04 do |io, h|
      h[:energy] = io.read_float
      h[:system] = io.read_int
    end

    decode :helm_jump, 0x0351a5ac, 0x05 do |io, h|
      h[:bearing] = io.read_float
      h[:distance] = io.read_float
    end

    decode :helm_set_impulse, 0x69cc01d9, 0x00 do |io, h|
      h[:velocity] = io.read_float
    end

    decode :helm_set_steering, 0x69cc01d9, 0x01 do |io, h|
      h[:rudder] = io.read_float
    end

    decode :keep_alive, 0xf5821226 do |io, h|
    end

  end

end
