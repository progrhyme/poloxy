desc 'Open an irb session preloaded with the library'
task :console do
  sh 'irb -rubygems -I lib -r poloxy'
end
task :c => :console

task :release do
  require_relative 'lib/poloxy'
  version = Poloxy::VERSION
  sh "git commit -m #{version}"
  sh "git tag -a v#{version} -m #{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
task :default => :spec

namespace :db do
  require_relative 'lib/poloxy'
  Sequel.extension :migration
  db = Poloxy::DataStore.new.connect

  desc "Apply DB schema by Sequel"
  task :migrate, [:version] do |t, args|
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrate", target: args[:version].to_i)
    else
      Sequel::Migrator.run(db, "db/migrate")
    end
    puts "Migration completed!"
  end

  desc "Reset DB by Sequel (drop all tables)"
  task :reset do
    Sequel::Migrator.run(db, "db/migrate", :target => 0)
    puts "DB Reset succeeded!"
  end
end
