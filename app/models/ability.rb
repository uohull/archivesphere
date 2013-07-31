class Ability
  include Hydra::Ability
  def custom_permissions
    if current_user && (current_user.groups.include? 'umg/up.dlt.archivesphere-admin-viewers')
      can :access, :site
    end
  end
end
