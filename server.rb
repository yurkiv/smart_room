require 'rubygems'
require 'sinatra'
require 'ohm'
require 'dotenv'
require_relative 'room'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load

set :port, 3000
set :environment, :production

configure :production do
  Ohm.redis = Redic.new(ENV['REDIS_URL'])
end

before { content_type :json }

post '/init_rooms' do
  Ohm.flush
  Room.create(name: 'Room 1', available: false)
  { status: :ok }.to_json
end

get '/rooms' do
  rooms = Room.all.to_a.map(&:serialize)
  content_type :json
  rooms.to_json
end

get '/rooms/:id' do
  room = Room[params[:id].to_i]
  room.serialize.to_json
end

put '/rooms/:id' do
  room = Room[params[:id].to_i]
  room.update(available: params[:available])
  room.serialize.to_json
end
