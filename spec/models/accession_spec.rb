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
    let (:accession) { Accession.new( accession_num:'123', disk_num:'123', disk_image:'no', disk_label:'label') }
    it "should access attributes" do
      accession.accession_num.should == '123'
      accession.disk_num.should  == '123'
      accession.disk_image.should == 'no'
      accession.disk_label.should == 'label'
    end


    it "should have thumbnail data stream" do
      accession.apply_depositor_metadata(user)
      file = File.new(Rails.root + 'spec/fixtures/world.png')
      data = File.open("spec/fixtures/world.png", "rb") {|io| io.read}
      Sufia::GenericFile::Actions.create_content(accession, file, "original_filename", "thumbnail", user)
      accession.thumbnail.content.should_not be_nil
      accession.thumbnail.content.should == data
      accession.thumbnail.label.should == "original_filename"
    end
  end

  context "part of collection" do
    let (:collection) { define_collection }
    let (:accession) { define_accession }

    it "should allow access to the relatiobnship both ways" do
      collection.members << accession
      collection.save
      accession.reload
      accession.collections.should == [collection]
      collection.members.should == [accession]
    end
  end

  context "has member files" do
    let (:accession) { define_accession }
    let (:file1) {define_generic_file 'title 1'}
    let (:file2) {define_generic_file 'title 2'}
    it "should allow access to the file relationship" do
      accession.members << file1
      accession.members << file2
      accession.save
      file1.reload
      file2.reload
      accession.members == [file1, file2]
      file1.collections == [accession]
      file2.collections == [accession]
    end
  end

 
  describe "#sort_member_paths" do
    let (:user) { FactoryGirl.create(:user) }
    let (:members) { [SolrDocument.new(relative_path_tesim: 'astest/file1.txt'),
                      SolrDocument.new(relative_path_tesim: 'astest/level 1/file2.txt'),
                      SolrDocument.new(relative_path_tesim: 'astest/level 1/level1-2/file3.txt'),
                      SolrDocument.new(relative_path_tesim: 'astest/level 1/level1-2/level1-2-3/file4.txt')] }

    it "Should sort em" do
      tree = subject.sort_member_paths(members)
      member = tree["/astest"]["/astest/file1.txt"][:member]
      member.should_not be_nil
      member["relative_path_tesim"].should == "astest/file1.txt"
      member = tree["/astest"]["/astest/level 1"]["/astest/level 1/file2.txt"][:member]
      member.should_not be_nil
      member["relative_path_tesim"].should == "astest/level 1/file2.txt"
      member = tree["/astest"]["/astest/level 1"]["/astest/level 1/level1-2"]["/astest/level 1/level1-2/file3.txt"][:member]
      member.should_not be_nil
      member["relative_path_tesim"].should == "astest/level 1/level1-2/file3.txt"
      member = tree["/astest"]["/astest/level 1"]["/astest/level 1/level1-2"]["/astest/level 1/level1-2/level1-2-3"]["/astest/level 1/level1-2/level1-2-3/file4.txt"][:member]
      member.should_not be_nil
      member["relative_path_tesim"].should == "astest/level 1/level1-2/level1-2-3/file4.txt"

    end
  end
end
