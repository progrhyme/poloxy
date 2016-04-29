class Poloxy::Item
  include Poloxy::Function::Group

  def initialize config: nil
    @config = config || Poloxy::Config.new
    @data_model = Poloxy::DataModel.new
  end

  def create args
    params = args.dup
    params[:group] = str2group_path params[:group] || 'default'
    params[:level] = Poloxy::MIN_LEVEL if params[:level].to_i < Poloxy::MIN_LEVEL
    params[:expire_at] = params[:received_at] + @config.message['default_expire']
    item = @data_model.spawn 'Item', params
    item.save
    item
  end
end
