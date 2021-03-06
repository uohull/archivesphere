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

  before_filter :find_collections_with_edit_access, only: [:edit]
  around_filter  :set_presenter, except:[:index]

  # this is really unassigned just tyring to get around loading a specific object w/ load and authorize
  def index
    @collection = Collection.new(title:'Unassigned Ingests',description:'Ingests that are unassigned to any collection')

    query = "{!lucene}#{Solrizer.solr_name(:collection)}:unassigned"
    #default the rows to 100 if not specified then merge in the user parameters and the attach the collection query
    solr_params =  {rows:100}.merge(params.symbolize_keys).merge({:q => query})

    # run the solr query to find the collections
    (@response, @member_docs) = get_search_results(solr_params)
    find_collections_with_edit_access

    set_presenter
    render :unassigned
  end


  # Queries Solr for members of the collection.
  # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
  def query_collection_members
    query = params[:cq]

    #default the rows to 100 if not specified then merge in the user parameters and the attach the collection query
    solr_params =  {rows:100}.merge(params.symbolize_keys).merge({:q => query})

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
      format.html do
        if params["batch_document_ids"].blank?
          redirect_to "#{new_accession_path}?collection_id=#{@collection.noid}", notice: 'Collection was successfully created.'
        else
          redirect_to  collections.collection_path( @collection), notice: 'Collection was successfully created.'
        end
      end
      format.json { render json: @collection, status: :created, location: @collection }
    end
  end

  def initialize_fields_for_edit
    @collection.initialize_fields
  end

  #get the thumbnail and stuff it into the collection
  def grab_thumbnail()
    # save off the title since the create content does bad things with it
    title = @collection.title
    super(@collection)

    #restore the original title
    @collection.title = title
    @collection.save
  end

  # move the thumbnail out of the collection params so that the collection does not get it when it runs update_parameters
  def move_thumb_param
    return unless  params[:collection] && params[:collection][:thumbnail]
    params[:thumbnail] = params[:collection][:thumbnail]
    params[:collection].except!(:thumbnail)
  end

  # include filters into the query to only include the collection memebers
  def include_collection_ids(solr_parameters, user_parameters)
    return solr_parameters if (params[:action] == "index")
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << Solrizer.solr_name(:collection)+':"'+@collection.id+'"'
  end


  def after_update
    change_members = []
    batch.each do |pid|
      ActiveFedora::Base.find(pid, :cast=>true).update_index
    end

    if flash[:notice].nil?
      flash[:notice] = 'Collection was successfully updated.'
    end
    respond_to do |format|
      format.html { redirect_to collections.collection_path(@collection) }
      format.json { render json: @collection, status: :updated, location: @collection }
    end
  end


  def set_presenter
    @collection_presenter = CollectionPresenter.new(@collection, params)
    yield if block_given?
  end
end
