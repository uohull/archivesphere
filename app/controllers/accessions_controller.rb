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

class AccessionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include BlacklightAdvancedSearch::Controller
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]

  # this is a little bit of magic to copy the collection params to the accession params since the update wants it in the collection
  #  and the create wants it in the accession and our form is the same for update or create we are handling that here.
  prepend_before_filter :set_accession_params , only:[:create]

  before_filter :set_accession
  before_filter :filter_docs_with_read_access!, :except => [:show]
  before_filter :has_access?, :except => [:show]
  before_filter :initialize_fields_for_edit, only:[:edit, :new]
  layout "sufia-one-column"

  before_filter :set_parent_id, :only => [:new]
  AccessionsController.solr_search_params_logic += [:exclude_unwanted_models]

  before_filter :move_thumb_param, only: [:create,:update]
  after_filter :grab_thumbnail , only:[:create,:update]

  before_filter :remove_select_something

  #todo where should the delete go?
  def after_destroy (id)
    path = sufia.dashboard_index_path
    path = collections.collection_path(@accession.collections[0]) unless @accession.collections.blank?
    respond_to do |format|
      format.html { redirect_to path, notice: 'Collection was successfully deleted.' }
      format.json { render json: {id:id}, status: :destroyed, location: @accession }
    end
  end
  
  def initialize_fields_for_edit
    @accession.initialize_fields
  end

  def show
    (_, member_docs) = get_search_results({:q => params[:cq]}, :rows=>1004)
    @tree = @accession.sort_member_paths(member_docs)
    @html = ''
  end

  def edit
    (_, member_docs) = get_search_results({:q => params[:cq]}, :rows=>1004)
    @tree = @accession.sort_member_paths(member_docs)
    @html = ''
  end

  def after_create
    parent_id = params[:collection_id]
    unless parent_id.blank?
      parent = Collection.find(parent_id)
      parent.members << @collection
      parent.update_index
      parent.save
    end
    respond_to do |format|
      format.html { redirect_to accession_path(@accession), notice: 'Accession was successfully created.' }
      format.json { render json: @accession, status: :created, location: @accession }
    end
  end

  def after_update
    respond_to do |format|
      format.html { redirect_to accession_path(@accession), notice: 'Accession was successfully updated.' }
      format.json { render json: @accession, status: :updated, location: @accession }
    end
  end

  protected

  # include filters into the query to only include the collection memebers
  def include_collection_ids(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << Solrizer.solr_name(:collection)+':"'+@collection.id+'"'
  end


  private

  def set_parent_id
    @parent_id = params[:collection_id]
  end

  def set_accession
    @accession = @collection
  end

  # this is a little bit of magic to copy the collection params to the accession params since the update wants it in the collection
  #  and the create wants it in the accession and our form is the same for update or create we are handling that here.
  def set_accession_params
    move_thumb_param
    logger.warn "\n\n\n before create #{params[:collection]}"
    params[:accession] ||= params[:collection]
  end

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:GenericFile\""
  end

  #get the thumbnail and stuff it into the accession
  def grab_thumbnail()
    thumbnail = params[:thumbnail]
    return unless thumbnail
    if (@accession.virus_check (thumbnail)) == 0
      Sufia::GenericFile::Actions.create_content(@accession, thumbnail, thumbnail.original_filename, "thumbnail", current_user)
    end
  end

  # move the thumbnail out of the collection params so that the collection does not get it when it runs update_parameters
  def move_thumb_param
    return unless  params[:collection] && params[:collection][:thumbnail]
    params[:thumbnail] = params[:collection][:thumbnail]
    params[:collection].except!(:thumbnail)
  end

end
