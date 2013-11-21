namespace :mailer do
  desc "change mailer to test mode"
  task :test_mode, :roles => :web  do
    run <<-CMD.compact
    perl -pi -e 's/delivery_method = :sendmail/delivery_method = :test/g' #{current_path}/config/environments/production.rb &&
    touch #{current_path}/tmp/restart.txt
    CMD
  end

  desc "change mailer to send mode"
  task :send_mode, :roles => :web  do
    run <<-CMD.compact
    perl -pi -e 's/delivery_method = :test/delivery_method = :sendmail/g' #{current_path}/config/environments/production.rb &&
    touch #{current_path}/tmp/restart.txt
    CMD
  end

end