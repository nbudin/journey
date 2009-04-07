ActionController::Routing::Routes.draw do |map|
  map.resources :questionnaires, :member => { :pagelist => :get, :available_special_field_purposes => :get } do |questionnaires|
    questionnaires.resources :pages, :name_prefix => nil, :collection => { :sort => :post } do |pages|
      pages.resources :questions, :name_prefix => nil, :collection => { :sort => :post }, :member => { :duplicate => :post, :edit_options => :get } do |questions|
        questions.resources :question_options, :name_prefix => nil, :collection => { :sort => :post }
      end
    end
    questionnaires.resources :responses, :name_prefix => nil, :collection => { :responseviewer => :get, :aggregate => :get, :print => :get }
  end

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.resources :larps

  map.root :controller => "questionnaires", :action => "index"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
