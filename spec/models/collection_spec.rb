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
  let(:user) { FactoryGirl.create :user }

  context "basic model" do
    let (:collection) { Collection.new( title:'123', description:'123', collection_num:'num') }
    it "should allows access to basic metadata" do
      collection.title.should == '123'
      collection.description.should == '123'
      collection.collection_num.should == 'num'
    end

    it "should have thumbnail data stream" do
      collection.apply_depositor_metadata(user)
      file = File.new(Rails.root + 'spec/fixtures/world.png')
      data = File.open("spec/fixtures/world.png", "rb") {|io| io.read}
      Sufia::GenericFile::Actions.create_content(collection, file, "original_filename", "thumbnail", user)
      collection.thumbnail.content.should_not be_nil
      collection.thumbnail.content.should == data
      collection.thumbnail.label.should == "original_filename"
    end

  end

  context "has member accessions" do
    let (:accession1) { define_accession '1' }
    let (:accession2) { define_accession '2'}
    let (:collection) {define_collection 'title 1'}
    it "should allow access to the accession collection members" do
      collection.members << accession1
      collection.members << accession2
      collection.save
      accession1.reload
      accession2.reload
      collection.members.should == [accession1, accession2]
      accession1.collections.should == [collection]
      accession2.collections.should == [collection]
    end
  end
end
