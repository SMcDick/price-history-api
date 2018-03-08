Rails.application.routes.draw do
  get 'prices/*type/all',               to: 'prices#all'
  get 'prices/*type/extrema',           to: 'prices#extrema'
  get 'prices/*type/average',           to: 'prices#average'
  get 'prices/*type/average/last-year', to: 'prices#last_year'
  get 'prices/*type/average/range',     to: 'prices#average_by_range'
  get 'buyback',                        to: 'buyback#index'
end
