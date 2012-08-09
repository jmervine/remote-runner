
task :yard do
  puts %x{ yardoc --protected ./lib/**/*.rb }
end

task :rspec do
  puts %x{ rspec }
end

task :finish => [ :rspec, :yard ]
