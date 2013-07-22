require 'spec_helper'

describe GenericFile do
  describe "auditing" do
    describe "when metadata is updated" do
      let (:user) { FactoryGirl.create(:user) }
      before do
        subject.audit(user, 'updated stuff')
      end
      it "should get an entry" do
        subject.audit_log.who.should == [user.user_key]
      end
    end
    describe "when content is updated" do
      it "should get an entry"
    end
    describe "when the object is deleted" do
      it "should get an entry"
    end
  end
end
