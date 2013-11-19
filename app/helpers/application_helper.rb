module ApplicationHelper

  def edit?
    params[:action] == "edit"
  end

  def new?
    params[:action] == "new"
  end

  def controller_name
    params[:controller]
  end

  def action_name
    params[:action]
  end

  def filter_user_collections(user_collections,collection)
    user_collections.reject {|a| a.noid == collection.noid}
  end

  def collection_cancel_path(collection=nil)
    path = sufia.dashboard_index_path unless edit?
    path = collections.collection_path(collection) if edit?
    path
  end

  def accession_cancel_path(accession=nil, collection=nil)
    if (edit?)
      path = accession_path(accession)
    elsif !collection.blank?
      path = collections.collection_path(collection)
    else
      path = sufia.dashboard_index_path
    end
    path
  end

  def page_title
    unless new?
      case controller_name
        when "accessions"
          title = "Ingest #{@accession.accession_num} - #{application_name}"
        when "collections"
          title = "#{@collection.title} - #{application_name}"
        when "generic_files"
          title = "#{@generic_file.title.join(", ")} - #{application_name}"
      end
    end
    logger.warn "\n\n Title: #{title}"
    title
  end

  def generate_breadcrumb
    render partial: "breadcrumbs", locals:{controller:controller_name, action:action_name} if ((["edit","show","new"].include? action_name) &&  (controller_name != "users")) || (action_name == "index" && controller_name == "collections")

  # if the view was not implemented just do not show them
  rescue ActionView::MissingTemplate
    logger.warn "A breadcrumb view has not yet been implemented for Controller: #{controller_name} Action: #{action_name}"
    nil
  end

  def display_access_users(users)
    nu = users.map do |u|
      User.find_by_user_key(u).name rescue u
    end
    nu.join(', ')
  end

end
