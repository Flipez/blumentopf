# frozen_string_literal: true

require './pot'

class Blumentopf
  class PotManager
    attr_accessor :pots

    def initialize
      @pots = []
    end
  end
end
