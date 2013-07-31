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

  rescue_from CanCan::AccessDenied, :with => :render_401

  protected

  def render_401
    render :template => '/error/401', :layout => "error", :formats => [:html], :status => 401
  end

  # Raises CanCan::AccessDenied if the user does not have access to the site.
  def restrict_user
    return if controller_name == 'sessions'
    authorize! :access, :site
  end

  def not_found
    raise ActionController::RoutingError.new('Restricted')
  end
end
