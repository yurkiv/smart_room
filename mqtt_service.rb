require 'rubygems'
require 'mqtt'
require 'ohm'
require 'dotenv'
require 'sentry-raven'
require_relative 'room'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load
Raven.configure { |config| config.dsn = ENV['SENTRY_URL'] }
Ohm.redis = Redic.new(ENV['REDIS_URL'])

Ohm.flush
Room.create(name: 'Big meeting room', available: true)
# Room.create(name: 'Room 2', available: false)

MQTT::Client.connect(ENV['MQTT_URL']) do |client|
  begin
    client.get('#') do |topic, message|
      puts "#{topic}: #{message}"
      case topic
      when 'meeting_room0'
        room = Room[1]
        room.update(available: message)
      # when 'meeting_room1'
      #   room = Room[2]
      #   room.update(available: message)
      end
    end
  rescue StandardError => e
    Raven.capture_exception(e)
  end
end
