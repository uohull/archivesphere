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

class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  after_filter :update_accession, :except => [:show,:destroy]


  # routed to /files/new
  def new
    @generic_file = ::GenericFile.new
    #get the collection and accession ids to pass to the form
    @collection_id = params["collection"]
    @accession_id = params["accession"]
    if @accession_id.blank?
      accession = Accession.create
      @accession_id = accession.id
    end
    @batch_noid = @accession_id
  end


  def update_accession
    @accession_id = params["accession_id"]
    @accession_id ||= params["batch_id"]
    #unless @accession_id.blank?
    #  logger.warn "Generic file #{@generic_file.inspect} #{@generic_files}"
    #  accession = Accession.find(@accession_id)
    #  @generic_files ||= [@generic_file] unless @generic_file.inner_object.class == ActiveFedora::UnsavedDigitalObject
    #  if (@generic_files)
    #    @generic_files.each {|gf|  accession.members << gf}
    #    accession.save
    #    @generic_files.each {|gf| gf.collections << accession; gf.update_index}
    #  end
    #
    #end
  end

  # override metadata creation to include accession into the metadata
  def create_metadata(file)
    accession_id = params["accession_id"]
    accession_id ||= params["batch_id"]
    accession = Accession.find(accession_id)
    file.collections << accession
    Sufia::GenericFile::Actions.create_metadata(file, current_user, nil)
  end

  def self.upload_complete_path(id)
    return Rails.application.routes.url_helpers.accession_path(id)
  end

  def self.destroy_complete_path(params)
    return Rails.application.routes.url_helpers.accession_path(params[:accession_id])
  end


  def perform_local_ingest
    if Sufia.config.enable_local_ingest && current_user.respond_to?(:directory)
      accession_id = params["accession_id"]
      accession_id ||= params["batch_id"]
      logger.warn "\n\n\n\n directory: #{current_user.directory}, files: #{params[:local_file]}, user: #{current_user.user_key}, id: #{accession_id}"
      Sufia.queue.push( IngestLocalJob.new( current_user.directory, params[:local_file], current_user.user_key, accession_id))
      redirect_to GenericFilesController.upload_complete_path( params[:batch_id]), {notice: "Your files are being uploaded in the background.  You will receive a notification when the upload is complete" }
    else
      flash[:alert] = "Your account is not configured for importing files from a user-directory on the server."
      render :new
    end
  end


end
