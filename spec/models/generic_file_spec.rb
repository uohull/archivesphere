require 'spec_helper'

describe GenericFile do
  let (:user) { FactoryGirl.create(:user) }

  describe "auditing" do
    describe "when metadata is updated" do
      before do
        subject.log_audit(user, 'updated stuff')
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

  describe "to_solr" do
    subject { FactoryGirl.build(:generic_file, relative_path: 'fortune/smiles/on/the/bold.mkv').to_solr }
    it "should have indexed relative_path" do
      subject['relative_path_tesim'].should == ['fortune/smiles/on/the/bold.mkv']
    end
  end

  describe "adding files" do
    subject { FactoryGirl.build :generic_file, user: user }
    describe "a png file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/world.png'), 'content', "world.png")
        subject.save!
        subject.reload
        subject.access_datastream.mimeType.should == 'image/jpeg'

        # it's not going to return the real preservation datastream, just proxy the original
        subject.datastreams['preservation'].should be_nil
        subject.preservation_datastream.mimeType.should == 'image/png' 
        subject.preservation_datastream.dsid.should == 'content' 
      end
    end

    describe "a tiff file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/Duck.tif'), 'content', "Duck.tif")
        subject.save!
        subject.reload
        subject.access_datastream.mimeType.should == 'image/jpeg'
        subject.preservation_datastream.mimeType.should == 'image/tiff'
      end
    end

    describe "an rtf file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/sample.rtf'), 'content', "sample.rtf")
        subject.save!
        subject.reload

        subject.access_datastream.mimeType.should == 'application/pdf'
        subject.preservation_datastream.mimeType.should == 'application/vnd.oasis.opendocument.text'
      end
    end

    describe "an doc file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/test.doc'), 'content', "test.doc")
        puts subject.inspect
        subject.save!
        subject.mime_type = "application/msword"
        subject.create_derivatives
        subject.reload
        puts subject.inspect
        subject.access_datastream.mimeType.should == 'application/pdf'
        subject.preservation_datastream.mimeType.should == 'application/vnd.oasis.opendocument.text'
      end
    end
  end

end
