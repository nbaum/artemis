require 'stringio'

module Artemis

  module Encoder

    module InstanceMethods
    end

    def self.encode (name, format, *args, &proc)
      prefix = args.pack(format)
      define_method("pack_#{name}") do |*args|
        instance_exec(*args, &proc)
      end
      InstanceMethods.__send__(:define_method, name) do |*args|
        p [name, *args]
        data = prefix + @codec.__send__("pack_#{name}", *args).to_s
        a = [0xdeadbeef, data.bytesize + 20, @codec.role, 0, data.bytesize, data]
        @codec.write(a.pack("LLLLLa*"))
      end
    end

    def pack_string (s)
      s = (s + "\0\0").encode("UTF-16LE")
      p [s.length, s].pack("La*")
    end

#    ## Client messages

#    encode :audio_command, 0x6aadc57f do |io, h|
#      h[:id] = io.read_int
#      h[:command] = io.read_int
#    end

#    encode :comms_outgoing, 0x574c4c4b do |io, h|
#      h[:recipient_type] = io.read_int
#      h[:recipient] = io.read_int
#      h[:message] = io.read_int
#      h[:target] = io.read_int
#    end

#    encode :gm_message, 0x809305a7 do |io, h|
#      h[:console] = io.read_byte
#      h[:sender] = io.read_string
#      h[:message] = io.read_string
#    end

#    encode_subtypes 0x4c821d3c, :read_int

#    encode :captain_select, 0x4c821d3c, 0x11 do |io, h|
#      h[:target] = io.read_int
#    end

#    encode :climb_dive, 0x4c821d3c, 0x1b do |io, h|
#      h[:direction] = io.read_int
#    end

#    encode :eng_set_auto_damcon, 0x4c821d3c, 0x0c do |io, h|
#      h[:state] = io.read_int
#    end

#    encode :fire_tube, 0x4c821d3c, 0x08 do |io, h|
#      h[:tube] = io.read_int
#    end

#    encode :helm_request_dock, 0x4c821d3c, 0x07 do |io, h|
#    end

    encode :set_warp, "ll", 0x4c821d3c, 0x00 do |factor|
      [factor].pack("l")
    end

    encode :toggle_reverse, "lll", 0x4c821d3c, 0x18, 0 do
    end

#    encode :keystroke, 0x4c821d3c, 0x14 do |io, h|
#      h[:keycode] = io.read_int
#    end

    encode :ready, "lll", 0x4c821d3c, 0x0f, 0 do
    end

    encode :ready2, "lll", 0x4c821d3c, 0x19, 0 do
    end

    encode :scan, "ll", 0x4c821d3c, 0x13 do |id|
      [id].pack("l")
    end

#    encode :sci_select, 0x4c821d3c, 0x10 do |io, h|
#      h[:target] = io.read_int
#    end

    encode :set_beam_freq, "ll", 0x4c821d3c, 0x0b do |freq|
      [freq].pack("l")
    end

#    encode :set_main_screen, 0x4c821d3c, 0x01 do |io, h|
#      h[:view] = io.read_int
#    end

    encode :set_ship, "ll", 0x4c821d3c, 0x0d do |index = 1|
      [index].pack("l")
    end

    encode :set_ship_settings, "ll", 0x4c821d3c, 0x16 do |drive, type, name|
      [drive, type, 1].pack("lll") + pack_string(name)
    end

    encode :set_console, "ll", 0x4c821d3c, 0x0e do |console, selected = true|
      [console, selected ? 1 : 0].pack("ll")
    end

#    encode :set_console, 0x4c821d3c, 0x0e do |io, h|
#      h[:console] = io.read_int
#      h[:selected] = io.read_int
#    end

    encode :target, "ll", 0x4c821d3c, 0x02 do |id|
      [id].pack("l")
    end

#    encode :toggle_autobeams, 0x4c821d3c, 0x03 do |io, h|
#    end

#    encode :toggle_perspective, 0x4c821d3c, 0x1a do |io, h|
#    end

#    encode :toggle_red_alert, 0x4c821d3c, 0x0a do |io, h|
#    end

#    encode :toggle_shields, 0x4c821d3c, 0x04 do |io, h|
#    end

#    encode :unload_tube, 0x4c821d3c, 0x09 do |io, h|
#      h[:tube] = io.read_int
#    end

#    encode_subtypes 0x69cc01d9, :read_int

#    encode :convert_torpedo, 0x69cc01d9, 0x03 do |io, h|
#      h[:direction] = io.read_float
#    end

#    encode :eng_send_damcon, 0x69cc01d9, 0x04 do |io, h|
#      h[:team] = io.read_int
#      h[:x] = io.read_int
#      h[:y] = io.read_int
#      h[:z] = io.read_int
#    end

    encode :set_coolant, "ll", 0x69cc01d9, 0x00 do |system, value|
      [system, value].pack("ll")
    end

#    encode :keep_alive, 0xf5821226 do |io, h|
#    end

#    encode :load_tube, 0x69cc01d9, 0x02 do |io, h|
#      h[:tube] = io.read_int
#      h[:ordnance] = io.read_int
#    end

#    encode_subtypes 0x0351a5ac, :read_int

    encode :set_energy, "ll", 0x0351a5ac, 0x04 do |system, energy|
      [energy, system].pack("fl")
    end

    encode :jump, "ll", 0x0351a5ac, 0x05 do |bearing, distance|
      [bearing, distance].pack("ff")
    end

    encode :set_impulse, "ll", 0x0351a5ac, 0x00 do |f|
      [f].pack("f")
    end

#    encode :helm_set_steering, 0x0351a5ac, 0x01 do |io, h|
#      h[:rudder] = io.read_float
#    end

#    encode :keep_alive, 0xf5821226 do |io, h|
#    end

  end

end
