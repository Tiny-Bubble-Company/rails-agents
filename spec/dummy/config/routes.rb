Rails.application.routes.draw do
  mount RailsAgents::Engine => "/agents"
  root "playground#index"
  post "playground", to: "playground#create", as: :playground
end
