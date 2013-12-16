module CollectionBehavior
  extend ActiveSupport::Concern

  included do
    include Hydra::Collection
    include Sufia::ModelMethods
    include Sufia::Noid
    include Hydra::AccessControls::Visibility
    include Sufia::GenericFile::WebForm # provides initialize_fields method

    before_save :update_permissions
  end

  def update_permissions
    self.visibility = "open" unless self.visibility == "open"
    self.edit_groups = self.edit_groups << Archivesphere::Application.config.admin_access_group unless self.edit_groups.include? Archivesphere::Application.config.admin_access_group
  end

  def virus_check( file)
    Sufia::GenericFile::Actions.virus_check(file)
  end

  def record_version_committer(user)
    version = thumbnail.latest_version
    # thumbnail datastream not (yet?) present
    return if version.nil?
    VersionCommitter.create(:obj_id => version.pid,
                            :datastream_id => version.dsid,
                            :version_id => version.versionID,
                            :committer_login => user.user_key)
  end

  def content
    thumbnail
  end

  def image_avail?
    !thumbnail.content.blank?
  end

end
