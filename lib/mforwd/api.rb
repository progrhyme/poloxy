require 'sinatra/base'
require 'json'

require 'mforwd'

class MForwd::API < Sinatra::Application
  get '/' do
    content_type :json
    ['Hello, world!'].to_json
  end
end
