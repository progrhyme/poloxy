require 'sinatra/base'
require 'json'
require 'tilt/erb'

require_relative '../poloxy'

class Poloxy::WebAPI < Sinatra::Application
  set :erb, trim: '-'
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

  before do
    ctx
  end

  get '/' do
    call env.merge("PATH_INFO" => '/board')
  end

  post '/v1/item' do
    request.body.rewind
    data = JSON.parse request.body.read
    item = Poloxy::Item.new(config: @@config).create data

    content_type :json
    status 201
    { id: item.id, received_at: item.received_at }.to_json
  end

  get '/board/?*' do
    @action = '#board'

    graph = Poloxy::Graph.new config: config.graph
    group = '/%s' % [ params['splat'].join('/') ]
    @group_breadcrumb = group_to_breadcrumb group, base: '/board/'

    @node = graph.node group
    unless @node
      return erb :not_found
    end

    @last_alerted  = @node.updated_at.to_s
    @no_alert_span = seconds_to_time_view(Time.now - @node.updated_at)
    @param = view_alert_params(level: @node.current_level)
    @param[:style].merge! view_styles()

    @children = []
    @node.children.each do |c|
      stash = view_alert_params(level: c.current_level)
      stash[:level] = c.current_level
      stash[:group] = c.group
      stash[:relative_group] = stash[:group].sub(%r|#{group}|, '')
      @children << stash
    end

    @leaves = []
    @node.valid_leaves.each_pair do |name, leaf|
      stash = view_alert_params(level: leaf.current_level)
      stash[:level]      = title_with_level leaf.current_level
      stash[:item]       = name
      stash[:updated_at] = leaf.updated_at
      @leaves << stash
    end

    erb :board
  end

  get '/forwards/?*' do
    @action = '#forwards'
    message_dm = Poloxy::DataModel.new.load_class 'Message'
    group = '/%s' % [ params['splat'].join('/') ]
    @group_breadcrumb = group_to_breadcrumb group, base: '/forwards/'

    if group != '/'
      c_grp = group.sub(%r|^/|, '')
      messages = message_dm.filter(Sequel.ilike(:group, "#{c_grp}%")).reverse_order(:id).all
    else
      messages = message_dm.where.reverse_order(:id).all
    end
    @messages = messages.map do |m|
      message_to_view m
    end

    erb :forwards
  end

  get '/inwards/?*' do
    @action = '#inwards'
    item_dm = Poloxy::DataModel.new.load_class 'Item'
    group = '/%s' % [ params['splat'].join('/') ]
    @group_breadcrumb = group_to_breadcrumb group, base: '/inwards/'

    if group != '/'
      c_grp = group.sub(%r|^/|, '')
      items = item_dm.filter(Sequel.ilike(:group, "#{c_grp}%")).reverse_order(:id).all
    else
      items = item_dm.where.reverse_order(:id).all
    end
    @items = items.map do |i|
      item_to_view i
    end

    erb :inwards
  end

  get '/message/:id' do
    @action = '#forwards'

    message  = Poloxy::DataModel.new.find 'Message', params[:id]
    @message = message_to_view message

    item_dm = Poloxy::DataModel.new.load_class 'Item'
    @items = item_dm.where(message_id: params[:id]).reverse_order(:id).all.map do |i|
      item_to_view i
    end

    @group_breadcrumb = group_to_breadcrumb @message.group, base: '/forwards/'

    erb :message
  end

  get '/item/:id' do
    @action = '#inwards'
    item  = Poloxy::DataModel.new.find 'Item', params[:id]
    @item = item_to_view item
    @group_breadcrumb = group_to_breadcrumb @item.group, base: '/inwards/'
    erb :item
  end

  private

    def config
      @@config
    end
end
