# frozen_string_literal: true

require 'telegram/bot'
require 'yaml'

class Blumentopf
  class NotificationHandler
    attr_reader :telegram

    def initialize
      @config = YAML.load_file 'config.yml'

      @telegram_token = @config['telegram']['token']
      @telegram_chat_id = @config['telegram']['chat_id']

      @telegram = Telegram::Bot::Api.new(@telegram_token) if @telegram_token && @telegram_chat_id
    end

    def notify(text)
      return nil unless telegram

      telegram.send_message(chat_id: @telegram_chat_id,
                            text: text)
    end

    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end
  end
end
