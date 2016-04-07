class MForwd::DataStore
  def initialize config: nil
    @config = config || MForwd::Config.new.database
  end

  def connect
    conf = @config['connect']
    @conn = if conf['url']
      Sequel.connect conf['url']
    else
      Sequel.connect conf
    end
  end
end
