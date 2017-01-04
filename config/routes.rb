Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'

  resources :dashboard, only: []  do
    collection do
      get '/hosts', to: "dashboard#hosts"
      get '/setup', to: "dashboard#setup"
      get '/', to: "dashboard#index"
    end
  end  

  resources :host, only: []  do
    collection do
      post '/all', to: "host#all"
      post '/self', to: "host#self"
      post '/save', to: "host#save"
    end
  end

  resources :speedtest, only: []  do
    collection do
      post '/save', to: "speedtest#save"
      post '/fetch', to: "speedtest#fetch"
    end
  end  

  resources :vpn, only: []  do
    collection do
      post '/all', to: "vpn#all"
    end
  end

  resources :qos, only: []  do
    collection do
      post '/all', to: "qos#all"
    end
  end  

end
