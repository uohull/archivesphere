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

  before_filter  :add_ids, only:[:new]
  after_filter  :update_accession, only:[:create]
  def add_ids
    logger.warn "\n Got to add_ids \n\n"
    #get the collection and accession ids to pass to the form
    @collection_id = params["collection"]
    @accession_id = params["accession"]
    logger.warn "\n Got to add_ids #{@accession_id}\n\n"
    if @accession_id.blank?
      accession = Accession.create
      @accession_id = accession.id
    end
  end

  def update_accession
    @accession_id = params["accession_id"]
    logger.warn "\n Got to update accession id:#{@accession_id}: #{@accession_id.blank?} #{@generic_file}\n\n"
    unless @accession_id.blank?
      accession = Accession.find(@accession_id)
      logger.warn "\n\n Got accession #{accession} #{@generic_file.id}"
      accession.members << @generic_file
      accession.save
      logger.warn "\n\n Members #{accession.members}"
    end
  end
end
