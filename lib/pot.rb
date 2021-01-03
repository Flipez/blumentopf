# frozen_string_literal: true

require 'tinkerforge/bricklet_analog_in_v3'

class Blumentopf
  class Pot
    attr_reader :uid, :ipcon, :display
    attr_accessor :index

    def initialize(uid, ipcon, display)
      @index = index
      @uid = uid
      @ipcon = ipcon
      @display = display

      init_callback
      init_status_led
    end

    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    def bricklet
      @bricklet ||= BrickletAnalogInV3.new uid, ipcon
    end

    def moisture(value)
      air = 2400
      water = 1500

      100 - (((value - water) * 100) / (air - water))
    end

    private

    def init_callback
      bricklet.register_callback(BrickletAnalogInV3::CALLBACK_VOLTAGE) do |voltage|
        display.write_line (index + 2), 0, "Pot #{index}: #{moisture(voltage)} (#{voltage / 1000.0})"

        display.draw_pot(moisture(voltage), index)
      end
      bricklet.set_voltage_callback_configuration 1000, false, 'x', 0, 0
    end

    def init_status_led
      bricklet.set_status_led_config BrickletAnalogInV3::STATUS_LED_CONFIG_SHOW_STATUS
    end
  end
end
