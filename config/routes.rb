Hrguru::Application.routes.draw do

  devise_for :users,
    controllers: {
      omniauth_callbacks: 'omniauth_callbacks',
      sessions: 'sessions'
    },
    skip: [:sessions]

  devise_scope :user do
    get 'sign_in', to: 'welcome#index', as: :new_user_session
    delete 'sign_out', to: 'sessions#destroy'
  end

  authenticated :user do
    root 'dashboard#index', as: 'dashboard'
  end

  namespace :api do
    scope module: :v1 do

      resources :users, only: [:index, :show, :contract_users]
      resources :projects, only: [:index]
      resources :memberships, except: [:new, :edit]
    end
  end

  resources :users, only: [:index, :show, :update]
  resources :available_users, only: [:index], path: "available"
  resources :projects
  resources :memberships, except: [:show]
  resources :teams
  resources :notes
  resources :roles, except: [:new, :edit, :destroy] do
    post 'sort', on: :collection
  end
  resources :positions, except: [:show]
  resources :abilities
  resources :users do
    resource :vacation do
      post 'import'
    end
  end
  get '/vacations', to: 'vacations#index'
  resources :settings, only: [:update]
  get '/settings', to: 'settings#edit'
  root 'welcome#index'
  get '/github_connect', to: 'welcome#github_connect'

  scope '/styleguide' do
    get '/css', to: 'pages#css'
    get '/components', to: 'pages#components'
  end

  resources :features, only: [ :index ] do
    resources :strategies, only: [ :update, :destroy ]
  end
  mount Flip::Engine => "/features"

end
