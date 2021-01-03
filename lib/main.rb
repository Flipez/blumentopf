# frozen_string_literal: true

require 'tinkerforge/ip_connection'

require_relative './menu'
require_relative './pot'
require_relative './pot_manager'
require_relative './display'
require_relative './touch'
require_relative './notification_handler'

include Tinkerforge

HOST = '192.168.178.87'
PORT = 4223

notification_handler = Blumentopf::NotificationHandler.new

ipcon = IPConnection.new
ipcon.connect HOST, PORT # Connect to brickd

ipcon.register_callback(IPConnection::CALLBACK_CONNECTED) do |reason|
  case reason
  when IPConnection::CONNECT_REASON_REQUEST
    puts 'Connected by request'
  when IPConnection::CONNECT_REASON_AUTO_RECONNECT
    puts 'Auto-Reconnect'
  end
end

ipcon.register_callback(IPConnection::CALLBACK_DISCONNECTED) do |reason|
  case reason
  when IPConnection::DISCONNECT_REASON_REQUEST
    notification_handler.notify('Disconnect requested by user')
  when IPConnection::DISCONNECT_REASON_ERROR
    notification_handler.notify('Disconnected by error')
  when IPConnection::DISCONNECT_REASON_SHUTDOWN
    notification_handler.notify('Disconnect requested by device')
  end
end

pot_manager = Blumentopf::PotManager.new
display = Blumentopf::Display.new(ipcon)
menu = Blumentopf::Menu.new(display, pot_manager)
Blumentopf::Touch.new(ipcon, menu)

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

sleep(2)

notification_handler.notify("Blumentopf ready. Monitoring #{pot_manager.pots.size} pots")

puts 'Press key to exit'
$stdin.gets

ipcon.disconnect
