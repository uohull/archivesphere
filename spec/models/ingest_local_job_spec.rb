# encoding: UTF-8
# Copyright © 2012 The Pennsylvania State University
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

require 'spec_helper'

describe IngestLocalJob do

  let(:user) { FactoryGirl.create :user }
  let(:accession) {define_accession("1234", user)}
  before do
    User.any_instance.stub(:directory).and_return(fixture_path)
  end

  describe "valid ingest" do
    it "should check permissions for each file before updating" do
      FileUtils.cp File.join(fixture_path,"test.jpg"), File.join(fixture_path,"test2.jpg")
      IngestLocalJob.new(fixture_path,["test2.jpg"],user.user_key, accession.id).run
      user.mailbox.inbox[0].messages[0].subject.should == "Local File Ingest Complete"
      user.mailbox.inbox[0].messages[0].body.should_not include("Error")
      user.mailbox.inbox[0].messages[0].move_to_trash user
    end
  end
  describe "invalid ingest" do
    it "should check permissions for each file before updating" do
      IngestLocalJob.new(fixture_path,["world123.png"],user.user_key, accession.id).run
      user.mailbox.inbox[0].messages[0].subject.should == "Local File Ingest Complete"
      user.mailbox.inbox[0].messages[0].body.should include("Error")
      user.mailbox.inbox[0].messages[0].move_to_trash user
    end
  end

end
