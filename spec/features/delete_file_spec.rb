require 'spec_helper'
require 'features/common'

describe "Deleting a file from an accession", :js=>true do
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
      # No rows, because no files have been uploaded
      page.should have_selector('tr',text: "world.png")
    end
    click_on "Edit Accession"
    within ('#accession_table') do
      find(".dropdown-toggle").click
      click_on "Delete File"
      page.driver.browser.switch_to.alert.accept
    end

    within ('#accession_table') do
      # No rows, because no files have been uploaded
      page.should_not have_selector('tr',text: "world.png")
    end

  end
end
