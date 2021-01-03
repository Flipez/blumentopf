# frozen_string_literal: true

require 'tinkerforge/ip_connection'

require_relative './menu'
require_relative './pot'
require_relative './pot_manager'
require_relative './display'
require_relative './touch'

include Tinkerforge

HOST = '192.168.178.87'
PORT = 4223

ipcon = IPConnection.new
ipcon.connect HOST, PORT # Connect to brickd

pot_manager = Blumentopf::PotManager.new
display = Blumentopf::Display.new(ipcon)
menu = Blumentopf::Menu.new(display, pot_manager)
touch = Blumentopf::Touch.new(ipcon, menu)

ipcon.register_callback(IPConnection::CALLBACK_ENUMERATE) do |uid, _connected_uid, _position,
  _hardware_version, _firmware_version,
  device_identifier, _enumeration_type|

  if device_identifier == BrickletAnalogInV3::DEVICE_IDENTIFIER
    pot = Blumentopf::Pot.new(uid, ipcon, display)
    puts "found Pot #{pot.uid}"
    pot_manager.add_pot(pot)
    menu.draw
  end
end

ipcon.enumerate

puts 'Press key to exit'
$stdin.gets

ipcon.disconnect
