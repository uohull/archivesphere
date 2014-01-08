require 'spec_helper'


describe "link to a bad accession", :js=>true do
  include ActionView::Helpers::UrlHelper

  let(:approved_user) { FactoryGirl.create(:approved_user) }
  let(:job_user) {User.batchuser()}
  before do
    # Stub the ability to access the site to avoid an LDAP call
    ability = Ability.new(approved_user).tap do |a|
      a.can :access, :site
    end
    ApplicationController.any_instance.stub(:current_ability).and_return(ability)
    login_as (approved_user)
    job_user = User.batchuser()
    job_user.send_message(approved_user, link_to("Go to Ingest #abc123",Rails.application.routes.url_helpers.accession_path("archivesphere:abc123")), 'Local File Ingest Complete')
  end

  it "should redirect back to notifications" do
    visit Sufia::Engine.routes.url_helpers.notifications_path
    click_on "Go to Ingest #abc123"
    current_path.should == Sufia::Engine.routes.url_helpers.notifications_path
    page.should have_selector(".alert")
  end
end
