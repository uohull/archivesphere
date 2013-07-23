# Copyright © 2012 The Pennsylvania State University
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


  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task :ci => :environment do
    Rake::Task["jetty:config"].invoke
    Rake::Task["db:migrate"].invoke

    require 'jettywrapper'
    jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.expand_path(File.join(Rails.root, 'jetty'))})
    puts "\n\n #{jetty_params.inspect}\n\n"

    error = nil
    error = Jettywrapper.wrap(jetty_params) do
      # do not run the js examples since selenium is not set up for jenkins
      ENV['SPEC_OPTS']="-t ~js"      
      Rake::Task['spec'].invoke
    end
    raise "test failures: #{error}" if error
  end

end
