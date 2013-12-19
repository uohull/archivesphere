source 'http://rubygems.org'

gem 'rails', '4.0.1'

group :production, :integration do
  gem 'pg'
end

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'dalli', '2.6.4'
gem 'blacklight', '4.5.0'
gem 'hydra-head', '6.4.0'
gem 'sufia', '3.5.0'
gem 'jettywrapper'
gem 'font-awesome-sass-rails'

gem 'activerecord-import'
gem 'active_fedora_relsint', '0.3.0'
gem 'active-fedora', '6.7.0'
gem 'mail_form', github: 'plataformatec/mail_form', ref:'9eb221a9c5e3'

gem 'hydra-derivatives'
#gem 'hydra-derivatives', github: 'projecthydra/hydra-derivatives', ref: '11430ca8ef1b83b35'

gem 'hydra-collections', git: 'git://github.com/projecthydra/hydra-collections.git', ref:'b46f68282663bf579832b79fbef52be2cbed7120'
gem 'hydra-ldap', '0.1.0'

gem 'sqlite3'
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'

gem 'execjs', '1.4.0'
gem 'therubyracer', '0.10.2'

gem 'clamav', '0.4.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'

  gem 'uglifier', '>= 1.3.0'
  gem 'capybara'
  gem 'selenium-webdriver', '2.35'
  gem 'database_cleaner'
  gem 'launchy'
  #gem 'debugger'
  gem 'rubyzip', '0.9.9', :require => 'zip/zip'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'debugger'

# rake needs rspec in all environments
gem 'rspec'

# for cron jobs
gem 'whenever'

gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
group :development, :test do
  gem "mysql2"
  gem "rspec-rails"
  gem "jettywrapper"
  gem 'rspec-given'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'minitest'
  # capistrano deployments
  gem 'capistrano', '2.15.5'
  gem 'capistrano-rbenv', '1.0.5'
  gem 'capistrano-ext', '1.2.1'
  gem 'capistrano-notification', '0.1.1'
end
