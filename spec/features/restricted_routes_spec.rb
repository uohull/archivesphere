require 'spec_helper'

include Warden::Test::Helpers

describe_options = {type: :feature}
if ENV['JS']
  #describe_options[:js] = true
end

describe 'restricted routes', describe_options do
  before(:each) do
    Warden.test_mode!
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  after(:each) do
    Warden.test_reset!
    Resque.inline = @old_resque_inline_value
  end
  
  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:prefix) { Time.now.strftime("%Y-%m-%d-%H-%M-%S-%L") }
  let(:initial_title) { "#{prefix} Something Special" }
  let(:initial_file_path) { __FILE__ }
  let(:updated_title) { "#{prefix} Another Not Quite" }
  let(:updated_file_path) { Rails.root.join('app/controllers/application_controller.rb').to_s }

  describe 'test restricted routes' do
    let(:agreed_to_terms_of_service) { false }
    let (:test_urls) {[{url:'/collections/new',text:'Create new Collection'}, {url:'/accessions/new',text:'Create new Accession'},
                      {url:'/dashboard',text:'Dashboard'}, {url:'catalog',text:'Recently Uploaded'}]}
    it 'should  allow a user within the archivesphere-admin-viewers group' do
      login_as ("cam156")
      #to do how do I add the groups
      #user.stub(:groups).and_return (['umg/up.dlt.archivesphere-admin-viewers'])
      visit '/'
      test_urls.each  do |test|
        visit test[:url]
        page.has_content?(test[:text])
      end
    end
    it 'should not allow any user' do
      login_as (user.user_key)
      visit '/'
      test_urls.each  do |test|
        lambda {visit test[:url]}.should raise_error ActionController::RoutingError
      end
    end
    it 'should not allow non logged user' do
      test_urls.each  do |test|
        lambda {visit test[:url]}.should raise_error ActionController::RoutingError
      end
    end

  end
end