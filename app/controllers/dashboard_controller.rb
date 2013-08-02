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

require 'blacklight/catalog'
class DashboardController < ApplicationController
  include  Sufia::DashboardControllerBehavior

  self.solr_search_params_logic += [:include_only_collections]

  protected

  # Limits search results just to GenericFiles
  # @param solr_parameters the current solr parameters
  # @param user_parameters the current user-subitted parameters
  def include_only_collections(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Collection\""
  end
end
