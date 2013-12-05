class CollectionPresenter < Presenter

  def initialize(collection, params)
    super params
    @collection = collection
  end

  def crumbs( action)
    crumbs = super(action)
    if action == "show"
      crumbs << @collection.title
    elsif action == "edit"
      crumbs << link_to("show #{@collection.title}", Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.noid))
    elsif action == "index" && @params[:edit]
      crumbs << link_to("Unassigned", Rails.application.routes.url_helpers.unassigned_collection_path)
    elsif action != "action"
      crumbs << "Unassigned"
    end

    crumbs
  end

  def errors?
    @collection.errors.any?
  end

  def error_count
    @collection.errors.count
  end

  def errors
    @collection.errors.full_messages
  end
end