module ArchivalDerivatives
  extend ActiveSupport::Concern

  included do
    makes_derivatives do |obj| 
      case obj.mime_type
      when 'image/png'
        obj.transform_datastream :content, { :access => {format: 'jpg', datastream: 'access'} }
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
    datastreams['access']
  end

  # Sometimes the preservation datastream is the same as the original, so this method
  # interrogates RELS-INT first to see if there is a predicate indicating which 
  # datastream to use for access. If there isn't one, just return the 
  # datastream named 'preservation' 
  # @return the preservation datastream for this model.
  def preservation_datastream
    datastreams['preservation']
  end

  module ClassMethods
    # expanding Sufias understanding of what images are
    def image_mime_types
      super + ['image/x-bmp', 'image/x-pict', 'image/vnd.adobe.photoshop', 'image/tiff', 'image/x-targa']
    end
  end

end
