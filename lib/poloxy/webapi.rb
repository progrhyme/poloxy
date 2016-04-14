require 'sinatra/base'
require 'json'
require 'tilt/erb'

require_relative '../poloxy'

class Poloxy::WebAPI < Sinatra::Application
  require_relative 'webapi/context'
  require_relative 'webapi/functions'
  require_relative 'webapi/view'
  include Functions
  include View

  @@config = Poloxy::Config.new.tap do |c|
    set :root,  c.web['root']
    %w[views public_folder].each do |opt|
      set opt.to_sym, c.web[opt] if c.web[opt]
    end
  end

  before '/board*' do
    ctx
    #log.debug "Called /board*"
  end

  get '/' do
    call env.merge("PATH_INFO" => '/board')
  end

  #post '/v1.0/message' do
    #content_type :json
    #stash.to_json
  #end

  get '/board' do
    graph = Poloxy::Graph.new config: config.graph
    @node = graph.node
    @param = view_alert_params(level: @node.level)
    @param['style'].merge! view_styles()
    erb :board
  end

  private

    def config
      @@config
    end
end
