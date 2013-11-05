require 'sufia/models/generic_file/actions'

Sufia::GenericFile::Actions.class_eval do
    def self.create_metadata(generic_file, user, batch_id)

      generic_file.apply_depositor_metadata(user)
      generic_file.date_modified = generic_file.date_uploaded = Date.today

      if batch_id
        generic_file.add_relationship("isPartOf", "info:fedora/#{Sufia::Noid.namespaceize(batch_id)}")
      else
        logger.warn "unable to find batch to attach to"
      end
      yield(generic_file) if block_given?
      generic_file.save!
    end
end