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

require 'rspec/given'
require 'spec_helper'

describe Accession do

  context "basic model" do
    Given(:collection) { Collection.new( title:'123', description:'123', collection_num:'num') }
    Then {collection.title == '123'}
    Then {collection.description == '123'}
    Then {collection.collection_num == 'num'}
  end

  context "has member accessions" do
    Given(:accession1) { define_accession '1' }
    Given(:accession2) { define_accession '2'}
    Given(:collection) {define_collection 'title 1'}
    When { collection.members << accession1; collection.members << accession2; collection.save; accession1.reload; accession2.reload}
    Then { collection.members == [accession1, accession2]}
    Then { accession1.collections == [collection]}
    Then { accession2.collections == [collection]}
  end
end
