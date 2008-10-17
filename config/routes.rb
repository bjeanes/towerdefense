ActionController::Routing::Routes.draw do |map|
  # Resource routes
  map.resources :messages
  map.resources :users

  # Authentication routes
  map.resource :session

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/create_account', :controller => 'users', :action => 'new'
  
  # Static routes
  map.lobby 'lobby', :controller => "lobby"
  map.connect 'stream/:action', :controller => 'stream'

  # Game routes
  map.with_options :controller => "game" do |m|
    m.game 'game'
    m.connect 'game/start', :action => "start" 
    m.join_game 'game/join/:id', :action => "join"
  end  
  
  map.root :controller => "lobby", :action => "redirect_to_lobby"
end
