Hydra::Derivatives::Audio.class_eval do
  def options_for(format)
    "-f #{File.extname(@object.filename[0]).sub(".","")}"
  end

  def self.encode(path, options, output_file)
    execute "#{Hydra::Derivatives.ffmpeg_path} -y #{options} -i \"#{path}\" #{output_file}"
  end
end
