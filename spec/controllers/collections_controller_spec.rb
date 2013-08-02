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

describe CollectionsController do
  before(:each) { @routes = Hydra::Collections::Engine.routes }

  let(:user) { FactoryGirl.create :user }

  before do
    controller.stub(:has_access?).and_return(true)
    controller.stub(:restrict_user).and_return(true)
    User.stub(:groups).and_return([])
    sign_in user 
  end

  describe '#create' do
     context "valid collection post" do
      clear_collections
      Given {post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}}
      When (:collection) {Collection.all.last}
      Then {response.should redirect_to(Rails.application.routes.url_helpers.new_accession_path+"?collection_id=#{collection.id}")}
     end
  end

 describe '#update' do
    context "update collection metadata" do
     clear_collections
     Given (:collection) {define_collection 'title in', user.login}
     When {put :update, id:collection.pid, collection: {title:"updated title", description:"updated description"}}
     Then {response.should redirect_to(@routes.url_helpers.collection_path(collection))}
     Then {collection.reload.title.should == "updated title"}
     Then {collection.reload.description.should == "updated description"}
     end
  end

  describe '#destroy' do
    context "valid collection destroy" do
      clear_collections
      Given (:collection) {define_collection 'title 1', user.login}
      When {delete :destroy, :id=>collection.pid}
      Then {response.should redirect_to(Sufia::Engine.routes.url_helpers.dashboard_index_path)}
    end

  end
end
