Rails.application.routes.draw do

  resources :page_views, only: [:top_urls] do

    collection do
      get :top_urls
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
