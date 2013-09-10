Sufia::Jobs::CharacterizeJob.class_eval do
  alias_method :after_characterize_orig, :after_characterize
  def after_characterize
    after_characterize_orig
    unless generic_file.pdf? || generic_file.image? || generic_file.video?
      generic_file.create_derivatives
      generic_file.save
    end
  end
end