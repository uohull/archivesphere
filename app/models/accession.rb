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
class Accession < ActiveFedora::Base
  include Hydra::Collection
  include Hydra::Collections::Collectible
  include Sufia::ModelMethods
  include Sufia::Noid
  include Sufia::GenericFile::Permissions
  include Sufia::GenericFile::WebForm # provides initialize_fields method

  before_save :update_permissions

  after_find :set_loaded_members
  after_initialize :set_loaded_members

  has_metadata :name => "properties", :type => AccessionPropertiesDatastream
  has_file_datastream :name => "thumbnail", :type => FileContentDatastream

  delegate_to :properties, [:accession_num, :disk_num, :disk_image, :disk_label], :unique => true

  def terms_for_display
    [:accession_num, :disk_num, :disk_label, :disk_image, :date_modified, :date_uploaded]
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
    solr_doc[Solrizer.solr_name(:collection)] = "unassigned" if collection_ids.size == 0
    return solr_doc
  end

  def update_permissions
    self.set_visibility("open")
  end

  def sort_member_paths(members)    start = Time.now
    tree = {}
    unless (members.blank?)
      sorted = members.sort_by { |s| s.relative_path.blank? ?  s.label : s.relative_path }

      sorted.each do |s|
        current = tree
        s.relative_path.split("/").inject("") do |sub_path,dir|
          sub_path = File.join(sub_path, dir)
          current[sub_path] ||= {}
          current[sub_path][:member] = s if (sub_path == "/"+s.relative_path)
          current = current[sub_path]
          sub_path
        end
      end
    end

    tree
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

  def current_members
    ids_for_outbound(:has_collection_member)
  end

  def set_loaded_members
    @member_ids_at_load_time = current_members
  end

  def members_added
    (current_members - @member_ids_at_load_time)
  end

  def members_removed
    (@member_ids_at_load_time - current_members)
  end

  # cause the members to index the relationship
  def local_update_members
    ## this is not updating the index correctly since the member does not yet know it is a part of the
    ## collection.  How do we do this correctly?  Not sure.  It seems like we need to set the
    ## member outside of this loop.
    ## We are going to handel the update index in the controller for the GF
    ## so we do nothing here
    ## todo: what is below really should work
    #if self.respond_to?(:members)
    #  if (members_added.size > 0)
    #    members_added.each do |member_id|
    #      member = ActiveFedora::Base.find(member_id,cast:true)
    #      logger.warn "\n\n ****** updating member collections: #{member.collections}"
    #      member.reload.update_index
    #    end
    #  end
    #end
    @member_ids_at_load_time = current_members
  end

end
