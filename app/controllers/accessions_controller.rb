# -*- coding: utf-8 -*-
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

class AccessionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include BlacklightAdvancedSearch::Controller
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]
  before_filter :set_accession
  before_filter :filter_docs_with_read_access!, :except => [:show]
  before_filter :has_access?, :except => [:show]
  before_filter :initialize_fields_for_edit, only:[:edit, :new]
  layout "sufia-one-column"

  before_filter :set_parent_id, :only => [:new]


  #todo where should the delete go?
  #def after_destroy (id)
  #  respond_to do |format|
  #    format.html { redirect_to dashboard_path, notice: 'Collection was successfully deleted.' }
  #    format.json { render json: {id:id}, status: :destroyed, location: @collection }
  #  end
  #end
  
  def initialize_fields_for_edit
    @accession.initialize_fields
  end

  def update
    process_member_changes
    @accession.update_attributes(params[:accession].except(:members))
    if @accession.save
      after_update
    else
      after_update_error
    end
  end

  def delete
    @accession.destroy
  end 


  def after_create
    parent_id = params[:collection_id]
    logger.warn "Parent id = #{parent_id}"
    unless parent_id.blank?
      parent = Collection.find(parent_id)
      logger.warn "\n\nparent = #{parent}\n\n"
      parent.members << @accession
      parent.save
    end
    respond_to do |format|
      format.html { redirect_to accession_path(@accession), notice: 'Accession was successfully created.' }
      format.json { render json: @accession, status: :created, location: @accession }
    end
  end

  private

  def set_parent_id
    @parent_id = params[:collection_id]
  end

  def set_accession
    @accession = @collection
  end

end
