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
  map.connect 'stream/:action', :controller => 'stream'
  map.lobby 'lobby', :controller => "lobby"
  map.game 'game', :controller => "game"
  map.join_game 'game/join', :controller => "game", :action => "join"
  
  map.root :controller => "lobby", :action => "redirect_to_lobby"
end
