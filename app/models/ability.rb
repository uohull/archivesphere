class Ability
  include Hydra::Ability
  def custom_permissions
    if current_user && (current_user.groups.include? Archivesphere::Application.config.access_group)
      can :access, :site
    end
  end
end
