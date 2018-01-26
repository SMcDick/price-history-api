Rails.application.routes.draw do
  get 'prices/*type/all',     to: 'prices#all'

  get 'prices/*type/average', to: 'prices#average'

  get 'prices/*type/highest', to: 'prices#highest'

  get 'prices/*type/lowest',  to: 'prices#lowest'

  get 'buyback', to: 'buyback#index'
end
