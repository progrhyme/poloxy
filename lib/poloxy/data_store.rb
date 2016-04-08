class Poloxy::DataStore
  def initialize config: nil, logger: nil
    @config = config || Poloxy::Config.new.database
    @logger = logger
  end

  def connect
    conf = @config['connect']
    @conn = if conf['url']
      Sequel.connect conf['url']
    else
      Sequel.connect conf
    end
    @conn.loggers << @logger if @logger
    @conn
  end
end
