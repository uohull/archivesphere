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
require 'datastreams/collection_properties_datastream'

class Collection < ActiveFedora::Base
  include Hydra::Collection
  include Sufia::ModelMethods
  include Sufia::Noid
  include Sufia::GenericFile::Permissions
  include Sufia::GenericFile::WebForm # provides initialize_fields method

  before_save :update_permissions

  has_metadata :name => "properties", :type => CollectionPropertiesDatastream
  has_file_datastream :name => "thumbnail", :type => FileContentDatastream

  delegate_to :properties, [:collection_num], :unique => true


  def terms_for_display
    [:title, :description, :collection_num, :date_modified, :date_uploaded]
  end
  
  def terms_for_editing
    terms_for_display - [:date_modified, :date_uploaded]
  end
  
  # Test to see if the given field is required
  # @param [Symbol] key a field
  # @return [Boolean] is it required or not
  def required?(key)
    self.class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end
  
  def to_param
    noid
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name("noid", Sufia::GenericFile.noid_indexer)] = noid
    solr_doc[Solrizer.solr_name("image_avail", Sufia::GenericFile.noid_indexer)] = image_avail?
    index_collection_pids(solr_doc)
    return solr_doc
  end

  def update_permissions
    self.set_visibility("open")
  end

  def virus_check( file)
    stat = Sufia::GenericFile::Actions.virus_check(file)
    flash[:error] = "Virus checking did not pass for #{File.basename(file.path)} status = #{stat}" unless stat == 0
    stat
  end


  def record_version_committer(user)
    version = thumbnail.latest_version
    # thumbnail datastream not (yet?) present
    return if version.nil?
    VersionCommitter.create(:obj_id => version.pid,
                            :datastream_id => version.dsid,
                            :version_id => version.versionID,
                            :committer_login => user.user_key)
  end

  def content
    thumbnail
  end

  def image_avail?
    !thumbnail.content.blank?
  end


  def remove_all_members
    self.members.each do |member|
      member.reify! rescue
      member.to_solr # not sure why this to_solr is needed but it caused the removal and update to work
      member.collections.delete(self) if member.respond_to?(:collections)
      member.update_index
    end
  end

end
