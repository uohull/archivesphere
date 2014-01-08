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
  before_filter :clear_session_user
  before_filter :remove_login_error

  rescue_from CanCan::AccessDenied, :with => :render_401

  rescue_from ActiveFedora::ObjectNotFoundError, with: :render_missing_object

  protected

  def clear_session_user
    if request.nil?
      logger.warn "Request is Nil, how weird!!!"
      return
    end

    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    # logout clears the entire session including flash messages
    search = session[:search].dup if session[:search]
    request.env['warden'].logout unless user_logged_in?
    session[:search] = search
  end

  def render_401
    render :template => '/error/401', :layout => "error", :formats => [:html], :status => 401
  end

  def render_missing_object
    redirect_to :back, alert:"Object no longer exists."
  end

  # Raises CanCan::AccessDenied if the user does not have access to the site.
  def restrict_user
    return if controller_name == 'sessions'
    authorize! :access, :site
  end

  def not_found
    raise ActionController::RoutingError.new('Restricted')
  end

  def remove_select_something
    flash[:notice] = nil if flash[:notice] == "Select something first"
    logger.warn "\n\nflash #{flash[:notice]}\n\n"
  end

  def remove_login_error
    if user_logged_in?
      flash[:alert] = nil if flash[:alert] == "You need to sign in or sign up before continuing."
    end
  end

  protected
  def user_logged_in?
    user_signed_in? and remote_user_set?
  end

  def remote_user_set?
    return true if Rails.env.test?
    # Unicorn seems to translate REMOTE_USER into HTTP_REMOTE_USER
    if Rails.env.development?
      request.env['HTTP_REMOTE_USER'].present?
    else
      request.env['REMOTE_USER'].present?
    end
  end


  #get the thumbnail and stuff it into the accession
  def grab_thumbnail(model)
    thumbnail = params[:thumbnail]
    return unless thumbnail
    model.virus_check (thumbnail)
    Sufia::GenericFile::Actions.create_content(model, thumbnail, thumbnail.original_filename, "thumbnail", current_user)
  rescue Sufia::VirusFoundError => e
    flash[:error] = "Virus checking did not pass for #{File.basename(thumbnail.path)} error = #{e.message}"
  end

end
