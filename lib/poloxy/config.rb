class Poloxy::Config
  @@default = {
    'log' => {
      'level' => 'INFO',
    },
    'deliver' => {
      'min_interval' => "1 min",
      'item' => {
        'merger' => 'PerItem',
      },
      'mail' => {
        'default_from' => 'poloxy',
      },
    },
    'graph' => {
      'delimiter' => '/',
    },
    'message' => {
      'default_expire' => "2 hours",
      'default_snooze' => "30 min",
    },
    'view' => {
      'title' => {
        1 => 'CLEAR',
        2 => 'INFO',
        3 => 'NOTICE',
        4 => 'CAUTION',
        5 => 'WARNING',
        6 => 'ERROR',
        7 => 'FATAL',
        8 => 'EMERGENCY',
      },
      'abbrev' => {
        1 => 'OK',
        2 => 'INFO',
        3 => 'NOTICE',
        4 => 'CAUTION',
        5 => 'WARN',
        6 => 'ERROR',
        7 => 'FATAL',
        8 => 'EMERG',
      },
    },
    'data' => {
      'default_keep_period' => "2 days",
    },
    'web' => {
      'root' => File.expand_path('../../../webroot', __FILE__),
      'style' => {
        'alert' => {
          1 => 'success',
          2 => 'info',
          4 => 'warning',
          6 => 'danger',
        },
        'color' => {
          1 => 'green',
          2 => 'aqua',
          4 => 'yellow',
          6 => 'red',
        },
        'box' => 'jumbotron',
        'icon' => {
          1 => 'fa-check-circle-o',
          2 => 'fa-info-circle',
          3 => 'fa-exclamation-circle',
          4 => 'fa-exclamation-triangle',
          5 => 'fa-flash',
          6 => 'fa-fire',
          7 => 'fa-ban',
          8 => 'fa-close',
          9 => 'fa-ambulance',
        },
      },
    },
  }

  def initialize path: ENV['POLOXY_CONFIG'] || 'config/poloxy.toml'
    @mine = File.readable?(path) ? TOML.load_file(path) : {}
    @mine.deep_merge(@@default)

    # Parse time expression into numeric seconds
    [
      %w(deliver min_interval),
      %w(message default_expire),
      %w(message default_snooze),
      %w(data default_keep_period),
    ].each do |keys|
      val = @mine[keys[0]][keys[1]]
      if val.class != Fixnum
        @mine[keys[0]][keys[1]] = ChronicDuration.parse val
      end
    end
  end

  def method_missing method
    if @mine.has_key? method.to_s
      @mine[method.to_s]
    end
  end
end
