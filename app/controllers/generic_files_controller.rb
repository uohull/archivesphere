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

 before_filter :update_accession, :except => [:show,:destroy]
  prepend_before_filter :namespace_accession

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
  end

  # override metadata creation to include accession into the metadata
  def create_metadata(file)
    accession_id = params["accession_id"]
    accession_id ||= params["batch_id"]
    Sufia::GenericFile::Actions.create_metadata(file, current_user, nil)
    set_accession(file,accession_id)
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

  def namespace_accession
    params[:accession_id] = Sufia::Noid.namespaceize(params[:accession_id]) unless params[:accession_id].blank?
    params[:batch_id] = Sufia::Noid.namespaceize(params[:batch_id]) unless params[:batch_id].blank?
  end

  protected

  def set_accession(file,accession_id)
    #no need to set the accession if it is already set
    return if file.collections.index{|c|c.pid == accession_id}

    # grab a file lock so we will not cause overlap issues on accession and only get some of our files
    File.open("#{Archivesphere::Application.config.accession_statefile}_#{accession_id}", File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      accession = Accession.find(accession_id)
      file.collections << accession
      file.save
    end

  end

end
