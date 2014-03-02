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
      csv << ['Project', 'Member', 'Hours']
      sum = 0
      projects = {}
      # data rows
      daily_summaries.each do |project, daily_summary|
        name = project ? project.name : ''
        projects[name] ||= {}
        daily_summary.each do |d_s|
          projects[name][d_s.user.name] ||= 0
          projects[name][d_s.user.name] += d_s.hours
        end
      end

      projects.each do |project, user|
        user.each do |name, value|
        
          csv << [project, name, value.round(2)]
        end
      end

    end

  end
end
