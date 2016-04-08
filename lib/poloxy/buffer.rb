class Poloxy::Buffer
  @@list = 'buffer'

  def initialize config: nil, role: nil
    @config = config || Poloxy::Config.new
    if role == :server
      @role_config = @config.worker
    else
      @role_config = @config.api
    end
    redis  = Redis.new url: @role_config['redis_url'], driver: :hiredis
    @redis = Redis::Namespace.new(:poloxy, redis: redis)
  end

  # @param data [Array]
  def push *data
    @redis.lpush(@@list, data)
  end

  def pop_all
    data = []
    @redis.llen(@@list).times do
      data << @redis.rpop(@@list)
    end
    data
  end
end
