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

describe AccessionsController do
  let(:user) { FactoryGirl.create :user }

  before do
    controller.stub(:has_access?).and_return(true)
    User.stub(:groups).and_return([])
    sign_in user
  end

  describe '#create' do
     context "valid accession post" do
      clear_accessions
      Given {post :create, accession: {accession_num: "123", disk_num: "disk number"}}
      When (:accession) {Accession.all.last}
      Then {response.should redirect_to(Rails.application.routes.url_helpers.accession_path(accession))}
      Then {accession.accession_num.should == "123"}
      Then {accession.disk_num.should == "disk number"}
     end
  end

  describe '#destroy' do
    context "valid accession destroy" do
      clear_accessions
      Given (:accession) {define_accession 'accession num', user.login}
      When {delete :destroy, :id=>accession.pid}
      Then { expect {Accession.find(accession.id)}.to raise_error ActiveFedora::ObjectNotFoundError}
      #Then {response.should redirect_to(Sufia::Engine.routes.url_helpers.dashboard_index_path)}
    end

  end
end
