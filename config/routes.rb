# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'daily_summaries', :to => 'daily_summaries#index'
post 'daily_summaries', :to => 'daily_summaries#report'

get 'monthly_summaries', :to => 'monthly_summaries#index'
get 'monthly_summaries/edit_labor_hours', :to => 'monthly_summaries#edit_labor_hours'
post 'monthly_summaries', :to => 'monthly_summaries#report'
get 'monthly_summaries/context_menu', :to => 'monthly_summaries#context_menu'

get 'holidays', :to => 'holidays#index'
get 'holidays/new', :to => 'holidays#new'
post 'holidays', :to => 'holidays#create'
get 'holidays/:id/edit', :to => 'holidays#edit'
put 'holidays/:id', :to => 'holidays#update'
delete 'holidays', :to => 'holidays#destroy'
delete 'holidays/bulk_destroy', :to => 'holidays#bulk_destroy'
get 'holidays/context_menu', :to => 'holidays#context_menu'
