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

    describe "a jpg file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/test.jpg'), 'content', "test.jpg")
        subject.save!
        subject.reload
        subject.access_datastream.mimeType.should == 'image/jpeg'
        subject.preservation_datastream.mimeType.should == 'image/tiff'

        # it's not going to return the real web datastream, just proxy the access
        subject.datastreams['web'].should be_nil
        subject.web_datastream.mimeType.should == 'image/jpeg'
        subject.web_datastream.dsid.should == 'access'
      end
    end

    describe "a png file" do
      it "should create derivatives" do
        file_with_produced_access_and_thumbnail  'world.png',  'image/png', 'image/jpeg', 'image/png'

      end
    end

    describe "a JP2 file" do
      it "should create derivatives" do
        file_with_produced_access_and_thumbnail  'world.jp2',  'image/jp2', 'image/jpeg', 'image/png'

      end
    end

    describe "a tiff file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/Duck.tif'), 'content', "Duck.tif")
        subject.save!
        subject.reload
        subject.access_datastream.mimeType.should == 'image/jpeg'
        subject.preservation_datastream.mimeType.should == 'image/tiff'

        # it's not going to return the real web datastream, just proxy the access
        subject.datastreams['web'].should be_nil
        subject.web_datastream.mimeType.should == 'image/jpeg'
        subject.web_datastream.dsid.should == 'access'
      end
    end

    describe "a bmp file" do
      it "creates derivatives" do
        file_with_produced_preservation_and_access  'test1.bmp',  'image/x-bmp','image/tiff', 'image/jpeg'
      end
    end

    describe "a gif file" do
      it "creates derivatives" do
        file_with_produced_preservation_and_access  'dc217.gif',  'image/gif','image/tiff', 'image/jpeg'
      end
    end

    describe "a psd file" do
      it "creates derivatives" do
        file_with_produced_preservation_and_access  'John-OConnor_Spring-Reflections_example.psd',  'image/vnd.adobe.photoshop','image/tiff', 'image/jpeg'
      end
    end

    describe "a tga file" do
      it "creates derivatives" do
        file_with_produced_preservation_and_access  'CBW8.TGA',  'image/tga','image/tiff', 'image/jpeg'
      end
    end

    describe "a pct file" do
      it "creates derivatives" do
        file_with_produced_preservation_and_access  'BLK.PCT',  'application/octet-stream','image/tiff', 'image/jpeg'
      end
    end

    context "office documents", :office do

      describe "an rtf file" do
      it "should create derivatives" do
        subject.add_file(File.open(fixture_path + '/sample.rtf'), 'content', "sample.rtf")
        subject.mime_type = 'text/rtf'
        subject.save!
        subject.reload

        subject.access_datastream.mimeType.should == 'application/pdf'
        subject.preservation_datastream.mimeType.should == 'application/vnd.oasis.opendocument.text'
      end
    end


    describe "an doc file" do
      it "should create derivatives" do
        file_with_produced_web_and_thumbnail('test.doc', 'application/msword')
      end
    end

    describe "an docx file", travis_broken: true do
      it "should create derivatives" do
        file_with_produced_web_and_thumbnail('test.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      end
    end

    describe "an excel file" do
      it "should create derivatives" do
        file_with_produced_web_and_thumbnail('test.xls', 'application/vnd.ms-excel')
      end
    end

    describe "an open excel file", travis_broken: true do
      it "should create derivatives" do
        file_with_produced_web_and_thumbnail('test.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end
    end

    describe "an powerpoint file" do
      it "should create derivatives" do
        file_with_produced_access_and_thumbnail  'FlashPix.ppt',  'application/vnd.ms-powerpoint','application/pdf'
      end
    end

    describe "an open powerpoint file", travis_broken: true do
      it "should create derivatives" do
        file_with_produced_access_and_thumbnail  'FlashPix.pptx',  'application/vnd.openxmlformats-officedocument.presentationml.presentation','application/pdf'
      end
    end
    end

    describe "a wav file", travis_broken: true do
      it "should create derivatives" do
        file_with_produced_access_and_thumbnail  'piano_note.wav',  'audio/x-wav', 'audio/mpeg', nil

      end
    end

    describe "a mp3 file", travis_broken: true do
      it "should create derivatives" do
        file_with_produced_preservation  'horse.mp3', 'audio/mpeg',  'audio/wav'
      end
    end

    describe "an ac3 file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "diatonis_soal_48k.ac3", 'application/octet-stream',  'audio/wav', 'audio/mpeg'
      end
    end

    describe "a wma file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "wma9.wma", 'application/octet-stream',  'audio/wav', 'audio/mpeg'
      end
    end

    describe "an aiff file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "M1F1-AlawC-AFsp.aif", 'application/octet-stream',  'audio/wav', 'audio/mpeg'
      end
    end

    describe "an avi file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "countdown.avi", 'video/x-msvideo',  'video/mkv', 'video/mp4'
      end
    end

    describe "a flv file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "barsandtone.flv", 'video/x-flv',  'video/mkv', 'video/mp4'
      end
    end

    describe "a mov file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "sample_iTunes.mov", 'video/quicktime',  'video/mkv', 'video/mp4'
      end
    end

    describe "a mpg2 file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "sample_mpeg2.m2v", 'video/mpeg',  'video/mkv', 'video/mp4'
      end
    end

    describe "a mpg file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "MELT.MPG", 'video/mpeg',  'video/mkv', 'video/mp4'
      end
    end


    describe "a mpg4 file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "sample_mpeg4.mp4", 'video/mpeg',  'video/mkv', 'application/mp4'
      end
    end

    describe "a swf file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "Car-speakers-590x90.swf", 'application/x-shockwave-flash',  'video/mkv', 'video/mp4'
      end
    end

    describe "a wmv file", travis_broken: true do
      it "creates derivatives" do
        file_with_produced_preservation_and_access "ELL_PART_5_768k.wmv", 'video/x-ms-wmv',  'video/mkv', 'video/mp4'
      end
    end
  end

end

def file_with_produced_access_and_thumbnail (file_name, input_mime_type, access_mime_type, image_mime_type = 'image/jpeg')

  add_file(file_name)

  check_types input_mime_type, access_mime_type, access_mime_type
  subject.thumbnail.mimeType.should == image_mime_type

  # it's not going to return the real web preservation, just proxy the original
  mapped_preservation_content
  mapped_web_access

end

def file_with_produced_web_and_thumbnail (file_name, mime_type)

  add_file(file_name)

  check_types mime_type, mime_type, 'application/pdf'
  subject.thumbnail.mimeType.should == 'image/jpeg'

  # it's not going to return the real web preservation, just proxy the original
  mapped_preservation_content
  # it's not going to return the real web access, just proxy the original
  mapped_access_content
end

def file_with_produced_preservation(file_name, mime_type, preservation_mime_type)

  add_file(file_name)

  check_types preservation_mime_type, mime_type, mime_type

  # it's not going to return the real web access, just proxy the original
  mapped_access_content

end

def file_with_produced_preservation_and_access(file_name, mime_type, preservation_mime_type, access_mime_type)

  add_file(file_name)

  check_types preservation_mime_type, access_mime_type, access_mime_type

end


def add_file(file_name)
  subject.add_file(File.open(File.join(fixture_path ,file_name)), 'content', file_name)
  subject.save!
  subject.reload
end

def check_types (preservation_type, access_type, web_type)
  subject.web_datastream.mimeType.should ==  web_type
  subject.access_datastream.mimeType.should == access_type
  subject.preservation_datastream.mimeType.should == preservation_type
end


def mapped_preservation_content
  subject.datastreams['preservation'].should be_nil
  subject.preservation_datastream.dsid.should == 'content'
end

def mapped_access_content
  subject.datastreams['access'].should be_nil
  subject.access_datastream.dsid.should == 'content'
end

def mapped_web_content
  subject.datastreams['web'].should be_nil
  subject.web_datastream.dsid.should == 'content'
end

def mapped_web_access
  subject.datastreams['web'].should be_nil
  subject.web_datastream.dsid.should == 'access'
end