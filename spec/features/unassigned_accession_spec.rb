require 'spec_helper'

describe "Creating a new unassigned accession", :js=>true do
  let(:approved_user) { FactoryGirl.create(:approved_user) }
  before do
    # Stub the ability to access the site to avoid an LDAP call
    ability = Ability.new(approved_user).tap do |a|
      a.can :access, :site
    end
    ApplicationController.any_instance.stub(:current_ability).and_return(ability)
    login_as (approved_user)
  end

  it "should be successful" do
    clear_accessions
    visit '/'
    click_on "Unassigned Ingests"
    click_on "Create Ingest"
    fill_in "collection_accession_num", with: "Test #567"
    click_button "Create Accession"
    within ('#accession_table') do
      # No rows, because no files have been uploaded
      page.should_not have_selector('tr')
    end
    page.should_not have_button("Back to Collection")
  end
end
