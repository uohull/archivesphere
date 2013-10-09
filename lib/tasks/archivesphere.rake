# Copyright © 2013 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rdf'
require 'rdf/rdfxml'
require 'rubygems'
require 'action_view'
require 'rainbow'
require 'blacklight/solr_helper'
APP_ROOT="." # for jettywrapper
require 'jettywrapper'

include ActionView::Helpers::NumberHelper
include Blacklight::SolrHelper

namespace :archivesphere do

  desc "(Re-)Generate the secret token"
  task :generate_secret => :environment do
    include ActiveSupport
    File.open("#{Rails.root}/config/initializers/secret_token.rb", 'w') do |f|
      f.puts "#{Rails.application.class.parent_name}::Application.config.secret_token = '#{SecureRandom.hex(64)}'"
    end
  end

  desc 'copy fits configuration files into the fits submodule'
  task :fits_conf do
     puts 'copying fits config files'
     out =  `cp fits_conf/* fits/xml`
     puts "cp output #{out}"
     out2 =  `fits/fits.sh -i  spec/fixtures/test.docx`
     puts "ls output #{out2}"
  end

  #desc 'Spin up hydra-jetty and run specs'
  #task :ci => ['jetty:config', ] do
  #  puts 'running continuous integration'
  #  jetty_params = Jettywrapper.load_config
  #  error = Jettywrapper.wrap(jetty_params) do
  #    Rake::Task['spec'].invoke
  #  end
  #  raise "test failures: #{error}" if error
  #end


  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task :ci => :environment do
    `cp config/solr.yml.sample config/solr.yml`
    `cp config/fedora.yml.sample config/fedora.yml`
    `cp config/database.yml.sample config/database.yml`
    `cp config/redis.yml.sample config/redis.yml`
    `cp config/hydra-ldap.yml.sample config/hydra-ldap.yml`
    `git submodule init`
    `git submodule update`

    Rake::Task["jetty:config"].invoke
    Rake::Task["archivesphere:fits_conf"].invoke
    Rake::Task["archivesphere:generate_secret"].invoke
    Rake::Task["db:migrate"].invoke

    require 'jettywrapper'
    jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.expand_path(File.join(Rails.root, 'jetty'))})
    jetty_params["jetty_port"] = 8983
    puts "\n\n #{jetty_params.inspect}\n\n"

    error = nil
    error = Jettywrapper.wrap(jetty_params) do
      # do not run the js examples since selenium is not set up for jenkins
      ENV['SPEC_OPTS']="-t ~js"
      Rake::Task['spec'].invoke
    end
    raise "test failures: #{error}" if error
  end

  task :spec do
    Bundler.with_clean_env do
      within_test_app do
        Rake::Task['rspec'].invoke
      end
    end
  end

  desc "Clear LDPA load Times to force a reload from ldap"
  task :clear_ldap => :environment do
    User.all.each do |u|
      u.groups_last_update = nil
      u.ldap_last_update = nil
      u.save
    end
  end
end
