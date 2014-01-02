module MonthlySummariesHelper
	include AttendanceTrackingHelper
  
	def link_to_csv_export(params)
	  	link_to('CSV',
	        {
	            :controller => 'monthly_summaries',
	            :action => 'report',
	            :format => 'csv',
	            :monthly_summary_params => params
	        },
	        :method => 'post',
	        :class => 'icon icon-monthly_summaries')
	end
end
