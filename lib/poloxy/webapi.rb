require 'sinatra/base'
require 'json'
require 'tilt/erb'

require_relative '../poloxy'

class Poloxy::WebAPI < Sinatra::Application
  @@config = Poloxy::Config.new
  set :root,  @@config.web['root']
  set :views, @@config.web['views'] if @@config.web['views']

  get '/' do
    content_type :json
    ['Hello, world!'].to_json
  end

  get '/board' do
    erb :board
  end
end
