require 'sinatra/base'
require 'json'

require_relative '../poloxy'

class Poloxy::WebAPI < Sinatra::Application
  get '/' do
    content_type :json
    ['Hello, world!'].to_json
  end
end
