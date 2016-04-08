desc 'Open an irb session preloaded with the library'
task :console do
  sh 'irb -rubygems -I lib -r poloxy'
end
task :c => :console

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
