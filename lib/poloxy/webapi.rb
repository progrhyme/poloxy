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

  #post '/v1.0/message' do
    #content_type :json
    #stash.to_json
  #end

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
      [ :level, :group ].each do |key|
        stash[key] = c.send(key)
      end
      stash[:relative_group] = stash[:group].sub(%r|#{group}|, '')
      @children << stash
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
      vm = Poloxy::ViewModel::Message.from_data m
      vm.level_text = title_with_level m.level
      vm.style      = view_alert_params(level: m.level)[:style]
      vm
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
      vm = Poloxy::ViewModel::Item.from_data i
      vm.level_text = title_with_level i.level
      vm.style      = view_alert_params(level: i.level)[:style]
      vm
    end
    erb :inwards
  end

  get '/message/:id' do
    @action = '#forwards'
    message = Poloxy::DataModel.new.find 'Message', params[:id]
    @message = Poloxy::ViewModel::Message.from_data message
    @message.level_text = title_with_level @message.level
    @message.style      = view_alert_params(level: @message.level)[:style]
    item_dm = Poloxy::DataModel.new.load_class 'Item'
    @items = item_dm.where(message_id: params[:id]).reverse_order(:level).all.map do |i|
      vm = Poloxy::ViewModel::Item.from_data i
      vm.level_text = title_with_level i.level
      vm.style      = view_alert_params(level: i.level)[:style]
      vm
    end
    @group_breadcrumb = group_to_breadcrumb @message.group, base: '/forwards/'
    erb :message
  end

  get '/item/:id' do
    @action = '#inwards'
    item = Poloxy::DataModel.new.find 'Item', params[:id]
    @item = Poloxy::ViewModel::Item.from_data item
    @item.level_text = title_with_level @item.level
    @item.style      = view_alert_params(level: @item.level)[:style]
    @group_breadcrumb = group_to_breadcrumb @item.group, base: '/inwards/'
    erb :item
  end

  private

    def config
      @@config
    end
end
