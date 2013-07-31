require 'spec_helper'

describe 'restricted routes'  do
  let(:user) { FactoryGirl.create(:user) }
  let(:approved_user) { FactoryGirl.create(:approved_user) }
  let (:test_urls) {[{url:'/collections/new',text:'Create new Collection'}, {url:'/accessions/new',text:'Create new Accession'},
                    {url:'/dashboard',text:'Dashboard'}, {url:'catalog',text:'Recently Uploaded'}]}
  describe 'test restricted routes' do
    it 'should  allow a user within the archivesphere-admin-viewers group' do
      login_as (approved_user)
      visit '/'
      test_urls.each  do |test|
        visit test[:url]
        page.has_content?(test[:text])
      end
    end
    it 'should not allow any user' do
      login_as (user)
      visit '/'
      test_urls.each  do |test|
        page.status_code.should == 401
      end
    end
    it 'should not allow non logged user' do
      test_urls.each  do |test|
        visit test[:url]
        page.status_code.should == 401
      end
    end

  end
end
