# Example Usage:
#   deploy to staging: cap staging deploy
#   deploy a specific branch to qa: cap -s branch=cappy qa deploy
#   deploy a specific revision to staging: cap -s revision=c9800f1 staging deploy
#   deploy a specific tag to production: cap -s tag=my_tag production deploy
#   keep only the last 3 releases on staging: cap -s keep_releases=3 staging deploy:cleanup

require 'bundler/capistrano'
require 'capistrano-rbenv'
require 'capistrano/ext/multistage'

set :application, "archivesphere"

set :scm, :git 
set :deploy_via, :remote_cache
set :repository,  "https://github.com/psu-stewardship/#{application}.git"

set :deploy_to, "/opt/heracles/deploy/#{application}"
set :user, "deploy"
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")]
set :use_sudo, false
default_run_options[:pty] = true

set :rbenv_ruby_version, "2.0.0-p247"
set :rbenv_setup_shell, false

# override default restart task for apache passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

# insert new task to symlink shared files
namespace :deploy do
  desc "Link shared files"
  task :symlink_shared do
    run <<-CMD.compact
    ln -sf /dlt/#{application}/config_#{stage}/as/database.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/as/fedora.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/as/hydra-ldap.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/as/solr.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/as/redis.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/as/secret_token.rb #{release_path}/config/initializers/
    CMD
  end
end
before "deploy:finalize_update", "deploy:symlink_shared"

# Always run migrations.
after "deploy:update_code", "deploy:migrate"

# Resolrize.
namespace :deploy do
  desc "Re-solrize objects"
  task :resolrize, :roles => :solr do
    run <<-CMD.compact
    cd -- #{latest_release} && 
    RAILS_ENV=#{rails_env.to_s.shellescape} #{rake} archivesphere:resolrize
    CMD
  end
end
after "deploy:migrate", "deploy:resolrize"

# Restart resque-pool.
namespace :deploy do
  desc "restart resque-pool"
  task :resquepoolrestart do
    run "sudo /sbin/service resque restart"
  end
end
before "deploy:restart", "deploy:resquepoolrestart"

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
        PassengerRoot #{rbenv_path}/versions/#{rbenv_ruby_version}/lib/ruby/gems/2.0.0/gems/passenger-#{version}
        PassengerDefaultRuby #{rbenv_path}/versions/#{rbenv_ruby_version}/bin/ruby

        PassengerSpawnMethod smart
        PassengerPoolIdleTime 1000
        RailsAppSpawnerIdleTime 0
        PassengerMaxRequests 5000
        PassengerMinInstances 3

        #PassengerLogLevel 3
        #PassengerDebugLogFile /var/log/httpd/passenger_debug.log

        PassengerTempDir #{current_path}/tmp
        EOF

        put passenger_config, "/opt/heracles/deploy/.passenger.tmp"
        run <<-CMD.compact
        sudo /bin/mv /opt/heracles/deploy/.passenger.tmp /etc/httpd/conf.d/passenger.conf &&
        sudo /sbin/service httpd restart
        CMD
  end

  desc "warm up passenger"
  task :warmup, :roles => :web  do
    run "curl -s -k -o /dev/null --head https://$(hostname -f)"
  end
end
after "rbenv:setup", "passenger:install"
after "deploy:restart", "passenger:warmup"

# Keep the last X number of releases.
set :keep_releases, 5
#after "passenger:warmup", "deploy:cleanup"

# end
