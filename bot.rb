require 'slack-ruby-bot'
require 'dotenv'
require 'ohm'
require_relative 'room'

Dotenv.load
SlackRubyBot::Client.logger.level = Logger::INFO
Ohm.redis = Redic.new(ENV['REDIS_URL'])

class RoomBot < SlackRubyBot::Bot
  command 'state', 'ping' do |client, data|
    rooms = Room.all.to_a
    rooms_info = ''
    rooms_info = "you don't have rooms" if rooms.empty?
    rooms.each do |room|
      rooms_info << "#{room.name} is #{room_status(room)}\n"
    end

    client.say(text: rooms_info, channel: data.channel)
  end

  def self.room_status(room)
    room.available == 'true' ? 'available' : 'used'
  end
end

RoomBot.run