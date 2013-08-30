# -*- coding: utf-8 -*-
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

class CollectionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include BlacklightAdvancedSearch::Controller
  include Sufia::Noid # for normalize_identifier method
  include Hydra::Collections::SelectsCollections

  prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]
  before_filter :filter_docs_with_read_access!, :except => [:show]
  before_filter :has_access?, :except => [:show]
#  before_filter :initialize_fields_for_edit, only:[:edit, :new]
  layout "sufia-one-column"

  # remove the flash that requires the user to select something since we are not doing a batch edit
  before_filter :remove_select_something

  prepend_before_filter :move_thumb_param, only: [:create,:update]
  after_filter :grab_thumbnail , only:[:create,:update]

  before_filter :find_collections, only: [:edit]

  # Queries Solr for members of the collection.
  # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
  def query_collection_members
    query = params[:cq]

    #default the rows to 100 if not specified then merge in the user parameters and the attach the collection query
    solr_params =  {rows:100}.merge(params).merge({:q => query})

    # run the solr query to find the collections
    (@response, @member_docs) = get_search_results(solr_params)
  end


  def after_destroy (id)
    respond_to do |format|
      format.html { redirect_to sufia.dashboard_index_path, notice: 'Collection was successfully deleted.' }
      format.json { render json: {id:id}, status: :destroyed, location: @collection }
    end
  end

  def after_create
    respond_to do |format|
      format.html { redirect_to "#{new_accession_path}?collection_id=#{@collection.id}", notice: 'Collection was successfully created.' }
      format.json { render json: @collection, status: :created, location: @collection }
    end
  end

  def initialize_fields_for_edit
    @collection.initialize_fields
  end

  #get the thumbnail and stuff it into the collection
  def grab_thumbnail()
    thumbnail = params[:thumbnail]
    return unless thumbnail
    title = @collection.title
    @collection = @collection.reload
    if (@collection.virus_check (thumbnail)) == 0
      Sufia::GenericFile::Actions.create_content(@collection, thumbnail, thumbnail.original_filename, "thumbnail", current_user)
      @collection.title = title
      @collection.save
    end
  end

  # move the thumbnail out of the collection params so that the collection does not get it when it runs update_parameters
  def move_thumb_param
    return unless  params[:collection] && params[:collection][:thumbnail]
    params[:thumbnail] = params[:collection][:thumbnail]
    params[:collection].except!(:thumbnail)
  end

end