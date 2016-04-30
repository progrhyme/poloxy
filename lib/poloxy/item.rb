class Poloxy::Item
  include Poloxy::Function::Group

  def initialize config: nil
    @config = config || Poloxy::Config.new
    @data_model = Poloxy::DataModel.new
  end

  def create args, now: Time.now
    params = args.dup
    params['group'] = str2group_path params['group'] || 'default'
    params['level'] = Poloxy::MIN_LEVEL if params['level'].to_i < Poloxy::MIN_LEVEL
    params['received_at'] = now
    params['expire_at'] = now + @config.message['default_expire']
    item = @data_model.spawn 'Item', params
    item.save
    item
  end

  private

    def config
      @config
    end
end
