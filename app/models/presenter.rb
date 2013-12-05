class Presenter #< AbstractController::Base
  include ActionView::Helpers::UrlHelper

  def initialize(params)
    @params = params
  end

  def crumbs( action)
    crumbs = []
    crumbs << link_to('Dashboard', Rails.application.routes.url_helpers.root_path)
    crumbs
  end

  def editing?
    ((["edit"].include? @params[:action]) || ((["index"].include? @params[:action]) && !@params[:edit].nil?))
  end

end