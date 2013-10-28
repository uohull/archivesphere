Hydra::Derivatives::Video.class_eval do
  def options_for(format)
    extension = File.extname(@object.filename[0]).sub(".","").downcase
    input_options=""
    input_options= "-f #{extension}" unless ["m2v", "mpg", "wmv"].include? extension
    input_options= "-f mpeg" if ["m2v"].include? extension
    output_options = " -s #{size_attributes} #{codecs(format)}"

    if (format == "jpg")
      input_options +=" -itsoffset -2" unless ["swf"].include? extension
      output_options+= " -vframes 1 -an -f rawvideo"
    else
      output_options +=" #{video_attributes}  #{audio_attributes}"
    end

    {input_options:input_options, output_options:output_options}
  end


  def codecs(format)
    case format
      when 'mp4'
        "-vcodec libx264 -acodec libfdk_aac"
      when 'webm'
        "-vcodec libvpx -acodec libvorbis"
      when "mkv"
        "-vcodec ffv1"
      when "jpg"
        "-vcodec mjpeg"
      else
        raise ArgumentError, "Unknown format `#{format}'"
    end
  end

  def self.encode(path, options, output_file)
    execute "#{Hydra::Derivatives.ffmpeg_path} -y #{options[:input_options]} -i \"#{path}\" #{options[:output_options]} #{output_file}"
  end
end
