Hydra::Derivatives::Audio.class_eval do
  def options_for(format)
    extension = File.extname(@object.filename[0]).sub(".","").downcase
    "-f #{extension}" if ["ac3"].include? extension
  end

  def self.encode(path, options, output_file)
    execute "#{Hydra::Derivatives.ffmpeg_path} -y #{options} -i \"#{path}\" #{output_file}"
  end
end
