require 'slack-ruby-bot'
require 'dotenv'
require 'ohm'
require 'sentry-raven'
require_relative 'room'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load
SlackRubyBot::Client.logger.level = Logger::INFO
Raven.configure { |config| config.dsn = ENV['SENTRY_URL'] }
Ohm.redis = Redic.new(ENV['REDIS_URL'])

class RoomBot < SlackRubyBot::Bot
  command 'state', 'ping' do |client, data|
    begin
      rooms = Room.all.to_a
      rooms_info = ''
      rooms_info = "you don't have rooms" if rooms.empty?
      rooms.each do |room|
        rooms_info << "#{room.name} is #{room_status(room)}\n"
      end

      client.say(text: rooms_info, channel: data.channel)
    rescue StandardError => e
      Raven.capture_exception(e)
    end
  end

  def self.room_status(room)
    room.available == 'true' ? 'available' : 'used'
  end
end

RoomBot.run
