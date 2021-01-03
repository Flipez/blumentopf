# frozen_string_literal: true

require_relative './pot'

class Blumentopf
  class PotManager
    attr_accessor :pots

    def initialize
      @pots = []
    end

    def add_pot(pot)
      pot.index = pots.size
      pots << pot unless pots.include? pot
    end
  end
end
