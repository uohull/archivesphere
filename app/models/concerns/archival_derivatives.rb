module ArchivalDerivatives
  extend ActiveSupport::Concern

  included do
    makes_derivatives do |obj| 
      case obj.mime_type
      when 'image/png'
        obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'} }
        obj.rels_int.add_relationship(obj.content, :is_preservation_copy_of, obj.datastreams['content'])
        
      when 'image/x-bmp', 'image/gif', 'image/jpeg', 'image/x-pict', 'image/vnd.adobe.photoshop', 'image/tiff', 'image/x-targa'
        obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'},
                                             :preservation => {format: 'tiff', datastream: 'preservation'}}

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

  module ClassMethods
    # expanding Sufias understanding of what images are
    def image_mime_types
      super + ['image/x-bmp', 'image/x-pict', 'image/vnd.adobe.photoshop', 'image/tiff', 'image/x-targa']
    end
  end

end