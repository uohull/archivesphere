class DownloadsController < ApplicationController
  # module mixes in normalize_identifier method
  include Sufia::DownloadsControllerBehavior


  protected

  def datastream_to_show
    dsid = params[:datastream_id]
    unless dsid.blank?
      ds = asset.datastreams[dsid]
      ds ||= asset.send("#{dsid}_datastream")
    else
      ds = default_content_ds
    end
    raise "Unable to find a datastream for #{asset}" if ds.nil?
    ds
  end

end
