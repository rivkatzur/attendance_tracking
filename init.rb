require_dependency 'attendance_tracking/patches/time_entry_patch'


Redmine::Plugin.register :attendance_tracking do
  name 'Attendance Tracking plugin'
  author 'Rivka Tzur'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :application_menu, :daily_summary, { :controller => :daily_summaries, :action => :index }, :caption => 'Daily Summary', :if => Proc.new { User.current.logged? && User.current.allowed_to?(:view_all_daily_summaries, nil, :global => true) } 
  menu :project_menu, :daily_summary, { :controller => :daily_summaries, :action => :index }, :caption => :label_daily_summery
  menu :application_menu, :monthly_summary, { :controller => :monthly_summaries, :action => :index }, :caption => 'Monthly Summary', :if => Proc.new { User.current.logged? && User.current.allowed_to?(:view_all_monthly_summaries, nil, :global => true) } 
  menu :project_menu, :monthly_summary, { :controller => :monthly_summaries, :action => :index }, :caption => :label_monthly_summery

  project_module :daily_summaries do
    permission :view_all_daily_summaries,       	  :contracts => :index
  end

  project_module :monthly_summaries do
    permission :view_all_monthly_summaries,          :contracts => :index
  end
end

BusinessTime::Config.work_week = [:sun, :mon, :tue, :wed, :thu]

BusinessTime::Config.holidays = Holiday.all.map(&:date)
