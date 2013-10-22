Hydra::Derivatives::Image.class_eval do
  def load_image_transformer
    MiniMagick::Image.read(source_datastream.content, File.extname(@object.filename[0]))
  end
end
