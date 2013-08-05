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

  after_filter  :update_accession, only:[:create]

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
    logger.warn "\n\n\n Update accession #{@accession_id}: #{@generic_file} #{@generic_files}\n\n\n"
    unless @accession_id.blank?
      accession = Accession.find(@accession_id)
      if (@generic_files)
        @generic_files.each {|gf|  accession.members << gf}
      elsif (@generic_file)
        accession.members << @generic_file
      end
      accession.save
    end
  end

  def self.upload_complete_path(id)
    return Rails.application.routes.url_helpers.accession_path(id)
  end

end
