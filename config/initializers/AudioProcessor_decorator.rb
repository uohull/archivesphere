Hydra::Derivatives::Audio.class_eval do

  # I need to send ffmpeg input and output options to get -f in before the file and the other stuff after...
  def options_for(format)
    input_options=""
    output_options=""
    extension = File.extname(@object.filename[0]).sub(".","").downcase
    input_options= "-f #{extension}" if ["ac3"].include? extension

    {input_options:input_options, output_options:output_options}

  end

  #this is what I want option since I do not have access to the object at this point to see int he input extension
  def self.encode(path, options, output_file)
    execute "#{Hydra::Derivatives.ffmpeg_path} -y #{options[:input_options]} -i \"#{path}\" #{options[:output_options]} #{output_file}"
  end
end
