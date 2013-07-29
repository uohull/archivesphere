class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller  
# Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'sufia-one-column'

  protect_from_forgery

  before_filter :restrict_user

  protected

  def restrict_user
    render :template => '/error/401', :layout => "error", :formats => [:html], :status => 401 unless  current_user && (current_user.groups.include? 'umg/up.dlt.archivesphere-admin-viewers')
  end

  def not_found
    raise ActionController::RoutingError.new('Restricted')
  end
end
