# frozen_string_literal: true

require './pot_manager'

class Blumentopf
  class Menu
    attr_accessor :active_item
    attr_reader :oled, :pot_manager

    def initialize(oled, pot_manager)
      @active_item = 0
      @oled = oled
      @pot_manager = pot_manager
    end

    def items
      [
        { long: 'Overview', short: '#' },
        pots_to_menu,
        { long: 'Settings', short: '*' }
      ].flatten
    end

    def current
      draw_order = []
      items.each_with_index do |item, index|
        draw_order << if index == active_item
                        "[#{item[:long]}]"
                      else
                        " #{item[:short]} "
                      end
      end

      draw_order.join(' ')
    end

    def next
      return unless active_item < (items.size - 1)

      @active_item += 1
      draw
    end

    def back
      return unless active_item.positive?

      @active_item -= 1
      draw
    end

    def draw
      oled.write_line 1, 0, ' ' * 22
      oled.write_line 1, 0, current
    end

    private

    def pots_to_menu
      pot_manager.pots.to_enum.with_index.map do |_pot, index|
        { long: "Pot #{index}", short: index }
      end
    end
  end
end
