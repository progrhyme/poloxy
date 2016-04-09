class Poloxy::WebAPI::Context
  def initialize config: nil, log: nil
    @config    = config
    @datastore = Poloxy::DataStore.new config: config.database, logger: log
    @datastore.connect
  end
end
