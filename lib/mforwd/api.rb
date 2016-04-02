require 'sinatra/base'
require 'json'

require_relative '../mforwd'

class MForwd::API < Sinatra::Application
  get '/' do
    content_type :json
    ['Hello, world!'].to_json
  end
end
