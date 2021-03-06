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

# properties datastream: catch-all for info that didn't have another home.  Particularly depositor.
class AccessionPropertiesDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path=>"fields" ) 
    t.depositor :index_as=>[:stored_searchable]

    t.disk_num path: 'disk_num', :index_as=>:stored_searchable
    t.accession_num path: 'accession_num', :index_as=>:stored_searchable
    t.disk_label path: 'disk_label', :index_as=>:stored_searchable
    t.disk_image path: 'disk_image', :index_as=>:stored_searchable
    t.accession_type path: 'accession_type', :index_as=>:stored_searchable
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.fields
    end
    builder.doc
  end
end
