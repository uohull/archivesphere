Archivesphere::Application.routes.draw do
  root :to => "dashboard#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  Hydra::BatchEdit.add_routes(self)

  # Login/logout route to destroy session
  # get 'logout' => 'sessions#destroy', :as => :destroy_user_session
  # get 'login' => 'sessions#new', :as => :new_user_session

  resources :accessions, except: :index

  get 'collections/index' => "collections#index", as: :unassigned_collection

  devise_for :users


  # Administrative URLs
  namespace :admin do
    # Job monitoring
    constraints Sufia::ResqueAdmin do
      mount Resque::Server, :at => 'queues'
    end
  end

  mount Hydra::Collections::Engine => '/'
  mount Sufia::Engine => '/'

  delete 'notifications/:uid/delete' => 'mailbox#delete', :as => :mailbox_delete
end
