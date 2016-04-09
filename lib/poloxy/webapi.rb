require 'sinatra/base'
require 'json'
require 'tilt/erb'

require_relative '../poloxy'

class Poloxy::WebAPI < Sinatra::Application
  @@config = Poloxy::Config.new.tap do |c|
    set :root,  c.web['root']
    %w[views public_folder].each do |opt|
      set opt.to_sym, c.web[opt] if c.web[opt]
    end
  end

  get '/' do
    content_type :json
    ['Hello, world!'].to_json
  end

  get '/board' do
    erb :board
  end
end
