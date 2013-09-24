# Passenger.
namespace :passenger do
  desc "install (or upgrade) passenger gem and apache module"
  task :install, :roles => :web  do
    run <<-CMD.compact
    gem install passenger --no-ri --no-rdoc &&
    rbenv rehash &&
    passenger-install-apache2-module --auto
    CMD
    passenger.update_config
  end

  desc "Update passenger conf file"
  task :update_config, :roles => :web do
    version = 'ERROR' # default

    # passenger (2.X.X, 1.X.X)
    run("gem list | grep passenger") do |ch, stream, data|
      version = data.sub(/passenger \(([^,]+).*?\)/,"\\1").strip
    end

    puts "  passenger version #{version} configured"

    passenger_config =<<-EOF
        # This is created by capistrano. Refer to passenger:update_config
        LoadModule passenger_module #{rbenv_path}/versions/#{rbenv_ruby_version}/lib/ruby/gems/2.0.0/gems/passenger-#{version}/buildout/apache2/mod_passenger.so
        PassengerRoot #{rbenv_path}/versions/#{rbenv_ruby_version}/lib/ruby/gems/1.0.0/gems/passenger-#{version}
        PassengerDefaultRuby #{rbenv_path}/versions/#{rbenv_ruby_version}/bin/ruby

        PassengerSpawnMethod smart
        PassengerPoolIdleTime 1000
        RailsAppSpawnerIdleTime 0
        PassengerMaxRequests 5000
        PassengerMinInstances 3

        #PassengerLogLevel 3
        #PassengerDebugLogFile /var/log/httpd/passenger_debug.log

        PassengerTempDir /opt/heracles/deploy/passenger
        EOF

        put passenger_config, "/opt/heracles/deploy/passenger/.passenger.tmp"
        run <<-CMD.compact
        mkdir #{shared_path}/passenger &&
        sudo /bin/mv /opt/heracles/deploy/passenger/.passenger.tmp /etc/httpd/conf.d/passenger.conf &&
        sudo /bin/systemctl restart httpd
        CMD
        passenger.warmup
  end

  desc "warm up passenger"
  task :warmup, :roles => :web  do
    run "curl -s -k -o /dev/null --head https://$(hostname -f)"
  end
end

# end
