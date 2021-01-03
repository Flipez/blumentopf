# frozen_string_literal: true

require 'tinkerforge/ip_connection'
require 'tinkerforge/bricklet_analog_in_v3'
require 'tinkerforge/bricklet_oled_128x64_v2'
require 'tinkerforge/bricklet_multi_touch_v2'

require './menu'
require './pot'
require './pot_manager'

include Tinkerforge

HOST = '192.168.178.87'
PORT = 4223

ipcon = IPConnection.new
oled = BrickletOLED128x64V2.new 'NLa', ipcon
mt = BrickletMultiTouchV2.new 'LGh', ipcon

pot_manager = Blumentopf::PotManager.new
menu = Blumentopf::Menu.new(oled, pot_manager)

ipcon.connect HOST, PORT # Connect to brickd
# Don't use device before ipcon is connected

oled.clear_display
menu.draw

ipcon.register_callback(IPConnection::CALLBACK_DISCONNECTED) do |_reason|
  puts 'disconnecting'
end

ipcon.register_callback(IPConnection::CALLBACK_ENUMERATE) do |uid, connected_uid, position,
  hardware_version, firmware_version,
  device_identifier, _enumeration_type|

  if device_identifier == BrickletAnalogInV3::DEVICE_IDENTIFIER
    pot = Blumentopf::Pot.new(uid, connected_uid, position, hardware_version, firmware_version, device_identifier)
    puts 'found pot'
    puts "UID:     #{pot.uid}"
    puts "Position:          #{pot.position}"
    puts ''
    pot_manager.pots << pot unless pot_manager.pots.include? pot
    menu.draw
  end
end

ipcon.enumerate

mt.register_callback(BrickletMultiTouchV2::CALLBACK_TOUCH_STATE) do |state|
  menu.back if state[1]
  menu.next if state[2]
end

mt.set_touch_state_callback_configuration 100, true

def calculate_moisture(value)
  air = 2400
  water = 1500

  100 - (((value - water) * 100) / (air - water))
end

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

def draw_pot(percentage, index, oled)
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

pot_manager.pots.each_with_index do |pot, index|
  device = BrickletAnalogInV3.new pot.uid, ipcon
  device.set_status_led_config BrickletAnalogInV3::STATUS_LED_CONFIG_SHOW_STATUS

  device.register_callback(BrickletAnalogInV3::CALLBACK_VOLTAGE) do |voltage|
    oled.write_line (index + 2), 0, "Pot #{index}: #{calculate_moisture(voltage)} (#{voltage / 1000.0})"

    draw_pot(calculate_moisture(voltage), index, oled)
  end
  device.set_voltage_callback_configuration 1000, false, 'x', 0, 0
end

puts 'Press key to exit'
$stdin.gets

ipcon.disconnect
