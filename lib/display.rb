# frozen_string_literal: true

require 'tinkerforge/bricklet_oled_128x64_v2'
require 'forwardable'

class Blumentopf
  class Display
    extend Forwardable

    def_delegators :oled, :write_line

    attr_reader :oled

    def initialize(ipcon)
      @oled = BrickletOLED128x64V2.new 'NLa', ipcon

      oled.clear_display
    end

    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    def draw_pot(percentage, index)
      lines = []
      full_lines = percentage / 4 # because we have 25 lines
      full_lines.times do
        lines << full_line
      end
      (25 - full_lines).times do
        lines << empty_line
      end

      lines.reverse!
      lines << bottom_line

      oled.write_pixels 5 + (index * 35), 33, 34 + (index * 35), 63, lines.flatten
    end

    private

    def full_line
      Array.new(30, true)
    end

    def empty_line
      line = Array.new(30, false)
      line[0] = true
      line[-1] = true
      line
    end

    def bottom_line
      [1, 2, 4].map do |border|
        line = Array.new(30, true)
        x = 0
        until x == border
          line[x] = false
          line[-(x + 1)] = false
          x += 1
        end
        line
      end
    end
  end
end
