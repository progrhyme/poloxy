class Poloxy::Config
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
    graph: {
      'delimiter' => '/',
    },
    web: {
      'root' => File.expand_path('../../../webroot', __FILE__),
    },
  }

  def initialize path: ENV['POLOXY_CONFIG'] || 'config/poloxy.toml'
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
