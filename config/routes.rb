Rails.application.routes.draw do
  get 'dashboard/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'

  

  get '/servers/refresh', to: 'servers#refresh', as: :servers_refresh
  get '/servers/:id/setup', to: 'servers#setup', as: :server_setup
  get '/servers/:id/destroy', to: 'servers#destroy', as: :server_destroy
  post '/servers/new', to: 'servers#create'

  post '/images/:id/upload', :to => 'images#upload', as: :image_upload
  get '/images/:id/destroy', to: 'images#destroy', as: :image_destroy

  get '/containers/refresh', to: 'containers#refresh', as: :containers_refresh
  get '/containers/:id/destroy', to: 'containers#destroy', as: :container_destroy
  get '/containers/:id/stop', to: 'containers#stop', as: :container_stop
  get '/containers/:id/pause', to: 'containers#pause', as: :container_pause
  get '/containers/:id/unpause', to: 'containers#unpause', as: :container_unpause
  get '/containers/:id/restart', to: 'containers#restart', as: :container_restart
  get '/containers/:id/start', to: 'containers#start', as: :container_start
  get '/containers/:id/migrate', to: 'containers#migrate', as: :container_migrate


  get '/settings', to: 'settings#index', as: :settings

  get '/settings/nginx_update', to: 'settings#update', as: :settings_fix_upstream
  resources :images, :containers, :servers
  
end
