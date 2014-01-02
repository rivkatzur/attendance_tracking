module DailySummariesHelper

    include AttendanceTrackingHelper

	def link_to_csv_export(params)
    	link_to('CSV',
            {
              :controller => 'daily_summaries',
              :action => 'report',
              :format => 'csv',
              :daily_summary_params => params
            },
            :method => 'post',
            :class => 'icon icon-daily_summaries')
  	end

end
