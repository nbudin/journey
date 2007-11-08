ActionController::Routing::Routes.draw do |map|
  map.resources :questionnaires, :member => { :pagelist => :get } do |questionnaires|
    questionnaires.resources :pages do |pages|
      pages.resources :questions do |questions|
        questions.resources :question_options
      end
    end
  end

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.resources :larps
  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "synopsis", :action => "main"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
