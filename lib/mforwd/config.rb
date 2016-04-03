class MForwd::Config
  @@default = {
    log: {
      'level' => 'INFO',
    },
    api: {
      'redis_url' => 'redis://localhost:6379',
    },
    worker: {
      'redis_url' => 'redis://localhost:6379',
    },
    deliver: {
      'min_interval' => 60,
      'item' => {
        'merger' => 'Summary',
      },
    },
  }

  def initialize path: ENV['MFORWD_CONFIG'] || 'config/mforwd.toml'
    @mine = File.readable?(path) ? TOML.load_file(path) : {}
  end

  def method_missing method
    if @mine.has_key? method.to_s
      @mine[method.to_s]
    elsif @@default.has_key? method.to_sym
      @@default[method.to_sym]
    end
  end
end
