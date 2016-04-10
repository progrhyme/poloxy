require 'sequel'
require 'tempfile'

def mock_config
  toml = <<'EOTOML'
[log]
level  = "DEBUG"

[database.connect]
url = 'sqlite:/'
EOTOML
  tmp = Tempfile.open('tmp') do |fp|
    fp.puts toml
    fp
  end

  ENV['POLOXY_CONFIG'] = tmp.path
  Poloxy::Config.new
end

class TestPoloxy
  @@config = mock_config
  @@db     = nil

  class << self
    def config
      @@config
    end

    def init_db
      Sequel.extension :migration
      @@db = Poloxy::DataStore.new.connect
      Sequel::Migrator.run @@db, 'db/migrate'
    end

    def db
      @@db
    end
  end
end
