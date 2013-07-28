Journey::Application.routes.draw do
  devise_for :people, controllers: { cas_sessions: :journey_cas_sessions }
  
  resources :questionnaires do
    collection do
      get :responses
    end

    member do
      get :pagelist
      get :available_special_field_purposes
      get :customize
      get :export
      get :share
      get :preview
      get :print
    end

    resource :publish, :controller => 'publish', :only => :show do
      member do
        get :settings
      end
    end

    resources :pages, :except => [:new] do
      collection do
        post :sort
      end
    
      resources :questions, :except => [:new] do
        collection do
          post :sort
        end
        member do
          post :duplicate
          get :edit_options
        end
        resources :question_options, :except => [:new, :edit] do
          collection do
            post :sort
          end
        end
      end
    end

    resources :responses do
      collection do
        get :responseviewer
        get :aggregate
        get :print
        get :export
        get :subscribe
      end
    end
  end
  
  match '/answer/:id' => 'answer#index', :as => :questionnaire_answer
  scope '/answer/:id', as: 'questionnaire_answer', controller: 'answer' do
    get :resume
    match :preview, via: [:get, :post]
    get 'closed' => :questionnaire_closed
    get :prompt
    get :start
    post :save_answers
    get :save_session
  end

  match '/questionnaires/:questionnaire_id/responses/graphs/' => 'graphs#index', :as => :response_graphs
  match '/questionnaires/:questionnaire_id/responses/graphs/:action.:format' => 'graphs#index', :as => :response_graph
  match '/dashboard' => 'root#dashboard', :as => :dashboard
  match '/welcome' => 'root#welcome', :as => :welcome
  root to: 'root#index'
end
