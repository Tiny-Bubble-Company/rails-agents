Rails.application.routes.draw do
  root "playground#index"
  post "playground", to: "playground#create", as: :playground
end
