class DailySummary < ActiveRecord::Base
  unloadable

  belongs_to :user 
  validates_presence_of :hours, :spent_on
  validates :spent_on, :uniqueness => { :scope => [:user_id, :project_id] }

  ValidSelectOptions = {
    :project => 'Project',
    :user => 'User'
  }

  ValidPeriodType = {
    :free_period => 0,
    :default => 1
  }

  def self.prepare_daily_summary_csv(daily_summaries)
    summary_csv = FasterCSV.generate do |csv|
	  # header row
	  csv << ['project', 'member', 'date', 'hours']
	  sum = 0
	  # data rows
	  daily_summaries.each do |project, daily_summary|
      daily_summary.each do |d_s|

  	    csv << [
                project.nil? ? '' : project.name,
                d_s.user.name,
                d_s.spent_on,
                d_s.hours.round(2)
               ]
      end
      sum +=  daily_summary.map(&:hours).sum
	  end

	  # summary
	  csv << []
	  csv << ['', '', 'summary', sum.round(2)]
	end
  end
end
