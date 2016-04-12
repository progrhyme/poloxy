class Poloxy::Item
  include Poloxy::GroupFunction

  def initialize config: nil
    @config = config || Poloxy::Config.new
    @data_model = Poloxy::DataModel.new
  end

  def create args
    params = args.dup
    params[:group] = str2group_path params[:group] || 'default'
    item = @data_model.spawn 'Item', params
    item.save
    item
  end
end
