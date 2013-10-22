module ArchivalDerivatives
  extend ActiveSupport::Concern

  included do
    makes_derivatives do |obj|
      case obj.mime_type
      when 'image/png'
        obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'} }
        obj.rels_int.add_relationship(obj.content, :is_preservation_copy_of, obj.datastreams['content'])
        obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

      when 'image/bmp', 'image/gif', 'image/jpeg', 'image/x-pict', 'application/vnd.adobe.photoshop', 'image/vnd.adobe.photoshop', 'image/tiff', 'image/x-targa'
        obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'},
                                             :preservation => {format: 'tiff', datastream: 'preservation'}}
        obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

      when 'text/rtf'
        obj.transform_datastream :content, { :access => { :format=>'pdf' , datastream: 'access'},
                                             :preservation=> {:format => 'odf' , datastream: 'preservation'}  }, processor: 'document'
        obj.transform_datastream :access, { :access => {format: 'jpg', datastream: 'thumbnail'}}
        obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

      when 'application/msword', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        obj.transform_datastream :content, { :access => { :format=>'pdf' , datastream: 'web'} }, processor: 'document'
        obj.transform_datastream :web, { :access => {format: 'jpg', datastream: 'thumbnail'}}
        obj.rels_int.add_relationship(obj.content, :is_preservation_copy_of, obj.datastreams['content'])
        obj.rels_int.add_relationship(obj.content, :is_access_copy_of, obj.datastreams['content'])

      when 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        obj.transform_datastream :content, { :access => { :format=>'pdf'  , datastream: 'access'} }, processor: 'document'
        obj.transform_datastream :access, { :access => {format: 'jpg', datastream: 'thumbnail'}}
        obj.rels_int.add_relationship(obj.content, :is_preservation_copy_of, obj.datastreams['content'])
        obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

      when 'audio/x-wave'
        obj.transform_datastream :content, { :access => {format: 'mp3', datastream: 'access'} },processor: :audio
        obj.rels_int.add_relationship(obj.content, :is_preservation_copy_of, obj.datastreams['content'])
        obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

      when 'audio/mpeg'
        obj.transform_datastream :content, { :preservation => {format: 'wav', datastream: 'preservation'} },processor: :audio
        obj.rels_int.add_relationship(obj.content, :is_web_copy_of, obj.datastreams['content'])
        obj.rels_int.add_relationship(obj.content, :is_access_copy_of, obj.datastreams['content'])
      when 'application/octet-stream', 'audio/x-aiff', 'audio/x-ms-wma'
        if ([".tga",".pct"].include? File.extname(obj.filename[0]).downcase )
          obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'},
                                               :preservation => {format: 'tiff', datastream: 'preservation'}}
          obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])

        else
          obj.transform_datastream :content, { :preservation => {format: 'wav', datastream: 'preservation', input_format:"ac3"},
                                               :access => {format: 'mp3', datastream: 'access'} },processor: :audio
          obj.rels_int.add_relationship(obj.access, :is_web_copy_of, obj.datastreams['access'])
        end
    end

    end

  end


  # Sometimes a access datastream is the same as the original, so this method
  # interrogates RELS-INT first to see if there is a predicate indicating which 
  # datastream to use for access. If there isn't one, just return the 
  # datastream named 'access' 
  # @return the access datastream for this model.
  def access_datastream
    access_uri = rels_int.relationships(datastreams['content'], :is_access_copy_of).first
    if access_uri
      access_dsid = access_uri.object.to_s.split('/')[-1]
      datastreams[access_dsid]
    else
      datastreams['access']
    end
  end

  # Sometimes the preservation datastream is the same as the original, so this method
  # interrogates RELS-INT first to see if there is a predicate indicating which 
  # datastream to use for access. If there isn't one, just return the 
  # datastream named 'preservation' 
  # @return the preservation datastream for this model.
  def preservation_datastream
    preservation_uri = rels_int.relationships(datastreams['content'], :is_preservation_copy_of).first
    if preservation_uri
      preservation_dsid = preservation_uri.object.to_s.split('/')[-1]
      datastreams[preservation_dsid]
    else
      datastreams['preservation']
    end
  end

  # Sometimes the preservation datastream is the same as the original, so this method
  # interrogates RELS-INT first to see if there is a predicate indicating which
  # datastream to use for access. If there isn't one, just return the
  # datastream named 'preservation'
  # @return the preservation datastream for this model.
  def web_datastream
    web_uri = rels_int.relationships(datastreams['content'], :is_web_copy_of).first
    web_uri ||= rels_int.relationships(datastreams['access'], :is_web_copy_of).first
    if web_uri
      web_dsid = web_uri.object.to_s.split('/')[-1]
      datastreams[web_dsid]
    else
      datastreams['web']
    end
  end

  module ClassMethods
    # expanding Sufias understanding of what images are
    def image_mime_types
      super + ['image/x-bmp', 'image/x-pict', 'image/vnd.adobe.photoshop', 'image/tiff', 'image/x-targa']
    end
  end

end
