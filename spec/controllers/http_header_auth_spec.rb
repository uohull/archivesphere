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

describe CatalogController do
  describe "in development environment" do
    before do
      Rails.env = "development"
    end
    after do
      Rails.env = "test"
    end
    it "should allow you to fake auth using HTTP_REMOTE_USER" do
      @request.env["HTTP_REMOTE_USER"] = "cam156"
      xhr :get, :index
      controller.current_user.should_not be_nil
      controller.current_user.user_key.should == "cam156"
    end
  end
  describe "in non-development environment" do
    it "should NOT allow you to fake auth using HTTP_REMOTE_USER" do
      @request.env["HTTP_REMOTE_USER"] = "dmc186"
      xhr :get, :index
      controller.current_user.should be_nil
    end
  end
end