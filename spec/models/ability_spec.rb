require 'spec_helper'
require "cancan/matchers"

describe Ability do
  describe "an admin user" do
    subject { Ability.new(FactoryGirl.create(:approved_user))}
    it { should be_able_to(:access, :site) }
  end

  describe "a non-admin user" do
    subject { Ability.new(FactoryGirl.create(:user))}
    it { should_not be_able_to(:access, :site) }
  end
end
