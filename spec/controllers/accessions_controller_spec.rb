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

  after (:all) do
    User.all.each(&:destroy)
    GenericFile.all.each(&:destroy)
    Collection.all.each(&:destroy)
    Accession.all.each(&:destroy)
  end


  describe '#create' do
     context "post a valid accession" do
       it "creates accession" do

        #post as a collection since the form thinks of the accession as a collection.  This is how the views are sending information
        post :create, collection: {accession_num: "123", disk_num: "disk number"}
        accession = assigns[:accession]
        response.should redirect_to(Rails.application.routes.url_helpers.accession_path(accession))
        accession.accession_num.should == "123"
        accession.disk_num.should == "disk number"
       end

       it "allows for a thumbnail" do
         file = fixture_file_upload('/world.png','image/png')
         #post as a collection since the form thinks of the accession as a collection.  This is how the views are sending information
         post :create, collection: {accession_num: "123", disk_num: "disk number", thumbnail:file}
         accession = assigns[:accession]
         accession.thumbnail.mimeType.should == 'image/png'
         accession.thumbnail.label.should == 'world.png'
       end
     end

  end

  describe '#update' do
    let (:accession) {define_accession 'accession num', user.login}

    context "send update accession metadata" do
      it "modifies the accession" do
       put :update, id:accession.pid, collection: {accession_num:"456", disk_num:"disk number 456", disk_image:"yes", disk_label:"label 456"}
       response.should redirect_to(Rails.application.routes.url_helpers.accession_path(accession))
       accession.reload
       accession.accession_num.should == "456"
       accession.disk_num.should == "disk number 456"
       accession.disk_image.should == 'yes'
       accession.disk_label.should == 'label 456'
      end
     end
  end

  describe '#destroy' do
    let (:collection) {define_collection 'title', user.login}
    let (:accession) {define_accession 'accession num', user.login}
    context "delete a valid accession" do
      it "destroys the accession" do
        accession.collections = [collection]
        accession.save
        delete :destroy, :id=>accession.pid
        expect {Accession.find(accession.id)}.to raise_error ActiveFedora::ObjectNotFoundError
        response.should redirect_to(Hydra::Collections::Engine.routes.url_helpers.collection_path(collection))
        flash[:notice].should include("Ingest")
      end
    end
  end


  describe '#show' do
    let(:file1) { FactoryGirl.create(:generic_file, user: user, relative_path: 'fortune/smiles/on/the/bold.mkv', title:"bold.mkv") }
    let(:file2) { FactoryGirl.create(:generic_file, user: user, label: 'foo.txt', title:"foo.txt") }
    let(:file3) { FactoryGirl.create(:generic_file, user: user, relative_path: 'mouth/tooth.png',title:"tooth.png") }
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

  describe '#edit' do
    after do
      Collection.all.each(&:destroy)
    end
    let(:col1) { FactoryGirl.create(:collection, user: user, members: []) }
    let(:col2) { FactoryGirl.create(:collection, user: "jilluser", members: []) }
    let(:file1) { FactoryGirl.create(:generic_file, user: user, relative_path: 'fortune/smiles/on/the/bold.mkv', title:"bold.mkv") }
    let(:file2) { FactoryGirl.create(:generic_file, user: user, label: 'foo.txt', title:"foo.txt") }
    let(:file3) { FactoryGirl.create(:generic_file, user: user, relative_path: 'mouth/tooth.png',title:"tooth.png") }
    subject { FactoryGirl.create(:accession, user: user, members: [file1, file2, file3]) }

    it "edits all members" do
      # Below is needed to make the collections show up in the solr query
      col1.update_index
      col2.update_index
      # Above is needed to make the collections show up in the solr query

      get :edit, id: subject.pid
      member = assigns(:tree)["/fortune"]["/fortune/smiles"]["/fortune/smiles/on"]["/fortune/smiles/on/the"]["/fortune/smiles/on/the/bold.mkv"][:member]
      member.should_not be_nil
      member["id"].should == file1.id
      member = assigns(:tree)["/mouth"]["/mouth/tooth.png"][:member]
      member.should_not be_nil
      member["id"].should == file3.id
      member = assigns(:tree)["/foo.txt"][:member]
      member.should_not be_nil
      member["id"].should == file2.id

      assigns(:user_collections).should_not be_nil
      collections = assigns(:user_collections)
      collections.count.should == 1
      collections = collections.map{|doc| doc[:id]}
      collections.should include(col1.id)
      collections.should_not include(col2.id)
    end

  end
end
