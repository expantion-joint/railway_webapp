Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # devise
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations', # edit_user_registration_path
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    unlocks:       'users/unlocks'
  }

  devise_for :admins, controllers: {
    confirmations: 'admins/confirmations',
    registrations: 'admins/registrations', # edit_admin_registration_path
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    unlocks:       'admins/unlocks'
  }
  
  # home
  get '/', to: 'homes#index', as: 'index_home'
  get 'homes/policy', to: 'homes#policy', as: 'policy_home'
  get 'homes/terms', to: 'homes#terms', as: 'terms_home'

  # post
  get 'posts/index', to: 'posts#index', as: 'index_post'
  get 'posts/new', to: 'posts#new', as: 'new_post'
  post 'posts/new', to: 'posts#create', as: 'create_post'
  get 'posts/show/:post_id', to: 'posts#show', as: 'show_post'
  get 'posts/edit/:post_id', to: 'posts#edit', as: 'edit_post'
  post 'posts/edit/:post_id', to: 'posts#update', as: 'update_post'
  delete 'posts/destroy/:post_id', to: 'posts#destroy', as: 'destroy_post'

  # profile
  get 'profiles/new', to: 'profiles#new', as: 'new_profile'
  post 'profiles/new', to: 'profiles#create', as: 'create_profile'
  get 'profiles/show/:user_id', to: 'profiles#show', as: 'show_profile'
  get 'profiles/edit', to: 'profiles#edit', as: 'edit_profile'
  post 'profiles/edit', to: 'profiles#update', as: 'update_profile'

  # comment
  get 'posts/show/:post_id/comments/new', to: 'comments#new', as: 'new_comment'
  post 'posts/show/:post_id/comments/new', to: 'comments#create', as: 'create_comment'
  get 'posts/show/:post_id/comments/new_reply/:comment_id', to: 'comments#new_reply', as: 'new_reply_comment'
  post 'posts/show/:post_id/comments/newreply/:comment_id', to: 'comments#create_reply', as: 'create_reply_comment'
  delete 'comments/destroy/:comment_id', to: 'comments#destroy', as: 'destroy_comment'

  # like  
  post 'posts/:post_id/likes', to: 'likes#create', as: 'create_like'
  delete 'posts/:post_id/likes', to: 'likes#destroy', as: 'destroy_like'
  get 'likes/show', to: 'likes#show', as: 'show_like'

  # subscription
  get 'subscriptions/top', to: 'subscriptions#top', as: 'top_subscription'
  get 'subscriptions/new', to: 'subscriptions#new', as: 'new_subscription'
  post 'subscriptions/create_stripe_customer', to: 'subscriptions#create_stripe_customer', as: 'create_stripe_customer'
  get 'subscriptions/create_customer_portal', to: 'subscriptions#create_customer_portal', as: 'create_customer_portal'
  get 'subscriptions/payment_cancel', to: 'subscriptions#payment_cancel', as: 'payment_cancel'
  get 'subscriptions/checkout_success', to: 'subscriptions#checkout_success', as: 'checkout_success'
  get 'subscriptions/loading', to: 'subscriptions#loading', as: 'loading_subscription'
  get '/subscription_status', to: 'subscriptions#subscription_status'

  # contact
  get 'contacts/new', to: 'contacts#new', as: 'new_contact'
  post 'contacts/new', to: 'contacts#create', as: 'create_contact'

  # stripe
  post '/webhooks', to: 'webhooks#create'
  post '/checkouts', to: 'checkouts#create'

  # admin
  # user
  get 'admins/users/index', to: 'admins/users#index', as: 'index_admin_user'
  get 'admins/users/edit/:user_id', to: 'admins/users#edit', as: 'edit_admin_user'
  post 'admins/users/edit/:user_id', to: 'admins/users#update', as: 'update_admin_user'
  delete 'admins/users/destroy/:user_id', to: 'admins/users#destroy', as: 'destroy_admin_user'

  # post
  get 'admins/posts/index', to: 'admins/posts#index', as: 'index_admin_post'
  get 'admins/posts/media_index', to: 'admins/posts#media_index', as: 'media_index_admin_post'
  post 'admins/posts/media_index/:post_id', to: 'admins/posts#compress_media', as: 'compress_media_admin_post'
  delete 'admins/posts/destroy/:post_id', to: 'admins/posts#destroy', as: 'destroy_admin_post'

  # profile
  get 'admins/profiles/index', to: 'admins/profiles#index', as: 'index_admin_profile'
  get 'admins/profiles/media_index', to: 'admins/profiles#media_index', as: 'media_index_admin_profile'
  post 'admins/profiles/media_index/:profile_id', to: 'admins/profiles#compress_media', as: 'compress_media_admin_profile'
  delete 'admins/profiles/destroy/:profile_id', to: 'admins/profiles#destroy', as: 'destroy_admin_profile'

  # comment
  get 'admins/comments/index', to: 'admins/comments#index', as: 'index_admin_comment'
  delete 'admins/comments/destroy/:comment_id', to: 'admins/comments#destroy', as: 'destroy_admin_comment'

  # subscription
  get 'admins/subscriptions/index', to: 'admins/subscriptions#index', as: 'index_admin_subscription'
  get 'admins/subscriptions/edit/:subscription_id', to: 'admins/subscriptions#edit', as: 'edit_admin_subscription'
  post 'admins/subscriptions/edit/:subscription_id', to: 'admins/subscriptions#update', as: 'update_admin_subscription'
  delete 'admins/subscriptions/destroy/:subscription_id', to: 'admins/subscriptions#destroy', as: 'destroy_admin_subscription'

  # dashboard
  get 'admins/dashboards/index', to: 'admins/dashboards#index', as: 'index_admin_dashboard'

  # Sidekiq Web UI
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

end
