require 'spec_helper'

describe "Creating a new accession", :js=>true do
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
    create_base_collection_accession
    click_on "Add File(s)"
    test_file_path = Rails.root.join('spec/fixtures/world.png').to_s
    file_format = 'png (Portable Network Graphics)'

    page.execute_script(%Q{$("input[type=file]").css("opacity", "1").css("-moz-transform", "none");$("input[type=file]").attr('id',"fileupload");})

    attach_file "fileupload", test_file_path
    click_button "Start upload"

    within ('#accession_table') do
      # files should exist
      page.should have_selector('tr',text: "world.png")
      click_link ("world.png")
    end

    # check to be certain the creator is not set to the user ley
    row = find('tr', text: 'Creator')
    row.text.should_not include(approved_user.user_key)

  end
end
