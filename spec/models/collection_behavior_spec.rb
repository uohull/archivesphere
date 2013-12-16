require 'spec_helper'

class MyCollection < ActiveFedora::Base
  include CollectionBehavior
end

describe CollectionBehavior do
  subject {MyCollection.new}

  describe "update permissions" do
    it "responds to" do
      subject.should respond_to :update_permissions
    end

    it "set permissions to open and add admin group" do
      subject.update_permissions
      subject.edit_groups.should include(Archivesphere::Application.config.admin_access_group)
      subject.visibility.should == "open"
    end
  end

  describe "virus check" do
    it "responds to" do
      subject.should respond_to :virus_check
    end

    it "calls sufia virus check" do
      file = double(1)
      Sufia::GenericFile::Actions.should_receive(:virus_check).with(file)
      subject.virus_check(file)
    end
  end
end