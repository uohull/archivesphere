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

  has_metadata :name => "properties", :type => AccessionPropertiesDatastream

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

end
