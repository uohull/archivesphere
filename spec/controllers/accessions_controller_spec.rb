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

require 'spec_helper'

describe AccessionsController do
  let(:user) { FactoryGirl.create :user }

  before do
    controller.stub(:has_access?).and_return(true)
    controller.stub(:restrict_user).and_return(true)
    User.stub(:groups).and_return([])
    sign_in user
  end

  describe '#create' do
     context "valid accession post" do
      clear_accessions
      #post as a collection since the form thinks of the accession as a collection.  This is how the views are sending information
      Given {post :create, collection: {accession_num: "123", disk_num: "disk number"}}
      When (:accession) {Accession.all.last}
      Then {response.should redirect_to(Rails.application.routes.url_helpers.accession_path(accession))}
      Then {accession.accession_num.should == "123"}
      Then {accession.disk_num.should == "disk number"}
     end

     it "should allow for a thumnail" do
       file = fixture_file_upload('/world.png','image/png')
       #post as a collection since the form thinks of the accession as a collection.  This is how the views are sending information
       post :create, collection: {accession_num: "123", disk_num: "disk number", thumbnail:file}
       accession = assigns[:accession]
       accession.thumbnail.mimeType.should == 'image/png'
       accession.thumbnail.label.should == 'world.png'
     end
  end

  describe '#update' do
    context "update collection/accession metadata" do
     clear_accessions
     Given (:accession) {define_accession 'accession num', user.login}
     When {put :update, id:accession.pid, collection: {accession_num:"456", disk_num:"disk number 456", disk_image:"yes", disk_label:"label 456"}}
     Then {response.should redirect_to(Rails.application.routes.url_helpers.accession_path(accession))}
     Then {accession.reload.accession_num.should == "456"}
     Then {accession.reload.disk_num.should == "disk number 456"}
     Then {accession.reload.disk_image.should == 'yes'}
     Then {accession.reload.disk_label.should == 'label 456'}
     end
  end

  describe '#destroy' do
    context "valid accession destroy" do
      clear_accessions
      Given (:collection) {define_collection 'title', user.login}
      Given (:accession) {define_accession 'accession num', user.login}
      When { accession.collections = [collection]; accession.save}
      When {delete :destroy, :id=>accession.pid}
      Then { expect {Accession.find(accession.id)}.to raise_error ActiveFedora::ObjectNotFoundError}
      Then {response.should redirect_to(Hydra::Collections::Engine.routes.url_helpers.collection_path(collection))}
    end
  end


  describe '#show' do
    let(:file1) { FactoryGirl.create(:generic_file, user: user, relative_path: 'fortune/smiles/on/the/bold.mkv') }
    let(:file2) { FactoryGirl.create(:generic_file, user: user, label: 'foo.txt') }
    let(:file3) { FactoryGirl.create(:generic_file, user: user, relative_path: 'mouth/tooth.png') }
    subject { FactoryGirl.create(:accession, user: user, members: [file1, file2, file3]) }

    it "should show everything" do
      get :show, id: subject.pid
      member = assigns(:tree)["/fortune"]["/fortune/smiles"]["/fortune/smiles/on"]["/fortune/smiles/on/the"]["/fortune/smiles/on/the/bold.mkv"][:member]
      member.should_not be_nil
      member["id"].should == file1.id
      member = assigns(:tree)["/mouth"]["/mouth/tooth.png"][:member]
      member.should_not be_nil
      member["id"].should == file3.id
      member = assigns(:tree)["/foo.txt"][:member]
      member.should_not be_nil
      member["id"].should == file2.id
    end

    it "should show things that match the search" do
      get :show, id: subject.pid, cq: 'tooth.png'
      member = assigns(:tree)["/mouth"]["/mouth/tooth.png"][:member]
      member.should_not be_nil
      member["id"].should == file3.id
      member = assigns(:tree)["/fortune"]
      member.should be_nil
      member = assigns(:tree)["/foo.txt"]
      member.should be_nil
    end
  end
end
