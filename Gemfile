source 'https://rubygems.org'

gem 'rails', '4.0.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'blacklight'
gem 'hydra-head'
#gem 'sufia', github: 'projecthydra/sufia', ref: '7cb5169' #> 3.0.0
gem 'sufia', github: 'psu-stewardship/sufia', ref: '822107abd18b5' # redirect override & return of files create
gem 'jettywrapper'
gem 'font-awesome-sass-rails'

gem 'active_fedora_relsint', github: 'projecthydra/active_fedora_relsint', ref: 'f0c6bf091a4007e73b39efa4'
gem 'active-fedora', github: 'projecthydra/active_fedora', ref: 'eba5760' # > 6.4.3

#gem 'hydra-collections', git:'git://github.com/psu-stewardship/hydra-collections.git', ref:'ee120ae377138cc90fd94747a'
#gem 'hydra-collections', path:'../hydra-collections'
gem 'hydra-collections', git: 'git://github.com/projecthydra/hydra-collections.git', ref:'f0d36d3'
#gem 'hydra-collections'
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
  gem 'launchy'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
group :development, :test do
  gem "rspec-rails"
  gem "jettywrapper"
  gem 'rspec'
  gem 'rspec-given'
  gem 'factory_girl_rails', '~> 4.1.0'
end
