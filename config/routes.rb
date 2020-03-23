Rails.application.routes.draw do
  root to: 'pages#simulate'
  post '/', to: 'pages#simulate'
end
