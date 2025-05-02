Rails.application.routes.draw do
  devise_for :users

  # Giriş yapmayan kullanıcılar için giriş sayfasına yönlendirme
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  # Kullanıcı rolleri için yönlendirme
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
  end
  
  namespace :admin do
    resource :setting, only: [:edit, :update] do
      get :export_unassigned_students  # bu satırı ekle
      post :email_unassigned_students # e-posta için
      post :random_group_students  #  bunu ekle
    end
  end
  
  namespace :admin do
    resource :project_setting, only: [:edit, :update] do
      post :assign_random_projects
    end
  end
  
  namespace :admin do
    resources :advisors, only: [:new, :create]
  end
  

  namespace :advisor do
    get "dashboard", to: "dashboard#index", as: :dashboard
    get 'projects', to: 'projects#dashboard'
    get 'projects/manage', to: 'projects#manage'
    get 'groups', to: 'groups#index'

    resources :projects do
      collection do
        get :requests  # Teklifleri listeleyen sayfa için route
      end
    end
      # ProjectRequests için işlemleri burada tanımlıyoruz.
      resources :project_requests do
        member do
          patch :accept
          patch :reject
        end
      end
  
    resources :groups, only: [:new, :create, :edit, :update, :destroy]
  end
  
  
  namespace :student do
    get "dashboard", to: "dashboard#index"
  
    resources :groups, only: [:index, :new, :create, :show, :destroy] do
      resources :group_members, only: [:create, :destroy]
    end
  
    resources :projects, only: [:index] do
      resources :project_requests, only: [:new, :create]
  
      collection do
        get "published", to: "projects#published", as: :published
        get "proposals", to: "projects#proposals", as: :proposals
      end
    end
  end
end 