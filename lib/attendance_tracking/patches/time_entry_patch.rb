module AttendanceTracking
  require_dependency 'time_entry'

  module TimeEntryPatch
    def self.included(base)
      base.class_eval do 
        unloadable
        base.send(:include, InstanceMethods)
        after_validation :update_daily_summary
        after_destroy :update_daily_summary
      end
    end
    
    module InstanceMethods
      def update_daily_summary
        entry_hours = hours
        if new_record?
          entry_hours = hours
        elsif changed_attributes['hours']
          entry_hours = hours - changed_attributes['hours']
        elsif destroyed?
          entry_hours = -hours
        end
        unless entry_hours == 0
          d_s = DailySummary.where(:user_id => user_id, :project_id => project_id, :spent_on => spent_on).first_or_initialize
          d_s.hours = (d_s.hours || 0) + entry_hours
          d_s.save
        end
      end
    end
  end
  
  TimeEntry.send(:include, TimeEntryPatch)
end