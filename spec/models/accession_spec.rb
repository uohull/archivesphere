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
    Given(:accession) { Accession.new( accession_num:'123', disk_num:'123', disk_image:'no', disk_label:'label') }
    Then {accession.accession_num == '123'}
    Then {accession.disk_num == '123'}
    Then {accession.disk_image == 'no'}
    Then {accession.disk_label == 'label'}
  end

  context "part of collection" do
    Given(:collection) { define_collection }
    Given(:accession) { define_accession }
    When { collection.members << accession; collection.save; accession.reload}
    Then { accession.collections == [collection]}
    Then { collection.members == [accession]}
  end

  context "has member files" do
    Given(:accession) { define_accession }
    Given(:file1) {define_generic_file 'title 1'}
    Given(:file2) {define_generic_file 'title 2'}
    When { accession.members << file1; accession.members << file2; accession.save; file1.reload; file2.reload}
    Then { accession.members == [file1, file2]}
    Then { file1.collections == [accession]}
    Then { file2.collections == [accession]}
  end

 
  describe "#sort_member_paths" do
    let (:user) { FactoryGirl.create(:user) }
    let (:file1) { FactoryGirl.create(:generic_file, user: user, relative_path: '/astest/file1.txt') }
    let (:file2) { FactoryGirl.create(:generic_file, user: user, relative_path: '/astest/level 1/file2.txt') }
    let (:file3) { FactoryGirl.create(:generic_file, user: user, relative_path: '/astest/level 1/level1-2/file3.txt') }
    let (:file4) { FactoryGirl.create(:generic_file, user: user, relative_path: '/astest/level 1/level1-2/level1-2-3/file4.txt') }
    before do
      subject.members << file1 << file2 << file3 << file4
    end

    it "Should sort em" do
      subject.sort_member_paths.should == { 
        "/"=> {
          "/astest"=> {
            "/astest/file1.txt"=>{},
            "/astest/level 1"=> {
              "/astest/level 1/file2.txt"=>{},
              "/astest/level 1/level1-2"=> {
                "/astest/level 1/level1-2/file3.txt"=>{},
                "/astest/level 1/level1-2/level1-2-3"=> {
                  "/astest/level 1/level1-2/level1-2-3/file4.txt"=>{}
                }
              }
            }
          }
        }
      }
    end
  end
end
