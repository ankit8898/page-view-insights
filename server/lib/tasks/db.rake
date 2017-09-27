namespace :db do

  desc "Creates our database via Sequel"
  task :create do
    puts "Creating Database..."
  end

  desc "Create and run migrations"
  task :migrate, [:version] => [:environment]  do |t, args|
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(DB, "#{Rails.root}/db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(DB, "#{Rails.root}/db/migrations")
    end
  end

  desc "Seed database with dummy data"
  task seed: :environment do
    #system('bin/rails runner "Seeder.new(1_000_000, 10).seed"')
    Seeder.new(1_000_000, 10).seed
  end

end
