require 'fileutils'

yarn_build_command = case ARGV[0]
when 'development'
  "yarn build:dev"
when 'production'
  "yarn build:prod"
else
  "yarn build:prod"
end

puts "Building Client (React App) in #{ARGV[0]} mode"
begin
  # Building client react app
  system("cd client && #{yarn_build_command}")
  FileUtils.cp "#{FileUtils.pwd}/client/dist/index.html", "#{FileUtils.pwd}/server/public"
  FileUtils.cp "#{FileUtils.pwd}/client/dist/bundle.js", "#{FileUtils.pwd}/server/public"
  puts "*" * 30
  puts "Done. You can now cd server and bundle exec rails s"
  puts "*" * 30
rescue Exception => e
  puts "Failed: #{e.message}"
end
