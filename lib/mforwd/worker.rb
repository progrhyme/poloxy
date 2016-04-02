require 'sidekiq'

require 'mforwd'

Sidekiq.configure_client do |config|
  config.redis = {
    url:       'redis://localhost:6379',
    namespace: 'mforwd',
    size:      1
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
    url:       'redis://localhost:6379',
    namespace: 'mforwd'
  }
end

class MForwd::Worker
  include Sidekiq::Worker
  @@queued       = 0
  @@invoked      = 0
  @@last_invoked = 0
  @@config       = MForwd::Config.new

  def perform obj
    @@queued += 1
    p "#{@@queued}, #{obj.to_s}"
    if (Time.now - @@last_invoked).to_i >= config(:min_interval)
      invoke
      @@queued = 0
    end
  end

  def invoke
    @@invoked += 1
    @@last_invoked = Time.now
    p "invoked at #{@@last_invoked.to_s}"
  end

  def config key
    @@config.send(key)
  end
end
