# frozen_string_literal: true

require 'tinkerforge/bricklet_multi_touch_v2'

class Blumentopf
  class Touch
    attr_reader :menu, :ipcon

    def initialize(ipcon, menu)
      @menu = menu
      @ipcon = ipcon

      init_callback
    end

    def bricklet
      @bricklet ||= BrickletMultiTouchV2.new 'LGh', ipcon
    end

    private

    def init_callback
      bricklet.set_touch_state_callback_configuration 100, true
      bricklet.register_callback(BrickletMultiTouchV2::CALLBACK_TOUCH_STATE) do |state|
        menu.back if state[1]
        menu.next if state[2]
      end
    end
  end
end
