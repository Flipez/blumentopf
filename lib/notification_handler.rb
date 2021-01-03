# frozen_string_literal: true

require 'telegram/bot'
require 'yaml'

class Blumentopf
  class NotificationHandler
    attr_reader :telegram, :ipcon

    def initialize(ipcon)
      @ipcon = ipcon
      @config = YAML.load_file 'config.yml'

      init_telegram
      init_callbacks
    end

    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    def notify(text)
      return nil unless telegram

      telegram.send_message(chat_id: @telegram_chat_id,
                            text: text)
    end

    private

    def init_telegram
      @telegram_token = @config['telegram']['token']
      @telegram_chat_id = @config['telegram']['chat_id']

      @telegram = Telegram::Bot::Api.new(@telegram_token) if @telegram_token && @telegram_chat_id
    end

    def init_callbacks
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
          notify('Disconnect requested by user')
        when IPConnection::DISCONNECT_REASON_ERROR
          notify('Disconnected by error')
        when IPConnection::DISCONNECT_REASON_SHUTDOWN
          notify('Disconnect requested by device')
        end
      end
    end
  end
end
