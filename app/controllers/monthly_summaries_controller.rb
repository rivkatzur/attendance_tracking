class MonthlySummariesController < ApplicationController
  unloadable
  before_filter :authorize_global

  def index

  end

  def edit_labor_hours
  	User.update_all({:labor_hours => params[:monthly_summary][:labor_hours]}, :id => params[:monthly_summary][:ids])
	  redirect_to :action => 'index'
  end

  def report
  	@monthly_summaries = []
  	if params && params[:monthly_summary]
  		@users_ids = params[:monthly_summary][:users] || User.where(:status => User::STATUS_ACTIVE).sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  		@month = params[:monthly_summary][:month]
  		@year = params[:monthly_summary][:year]
  		retrieve_date_range
  		@business_days = @from.business_days_until(@to + 1.days)
  		@users_ids.each{|user| summary = get_summary_for_user(user); @monthly_summaries << summary unless summary.blank?}
  	else
  		redirect_to :action => 'index'
      	return
  	end
  	respond_to do |format|
    	format.html { render :action => 'details', :layout => false if request.xhr? }
      format.csv  { send_data prepare_monthly_summary_csv(@monthly_summaries), :filename => 'monthly_summaries.csv', :type => "text/csv" }
    end
  end

  def context_menu
    @users = User.find(params[:ids])
    render :layout => false
  end

  def retrieve_date_range
  	@from = Date.civil(@year.to_i, @month.to_i, 1)
	  @to = @from.end_of_month
  end

  def get_summary_for_user(user_id)
  	summary = {}
  	daily_summaries = TimeEntry.where('user_id = ? AND spent_on >= ? AND spent_on <= ?', user_id, @from, @to).order('user_id', 'spent_on')
  	sum = daily_summaries.sum('hours')
  	if sum > 0
  		user = User.find(user_id)
	  	summary[:daily_summaries] = daily_summaries
	  	summary[:sum] = sum.round(2)
	  	summary[:user_name] = user.name
	  	summary[:user_id] = user.id
  		summary[:labor_hours] = user.labor_hours || 'Unknown'
  		summary[:percent] = user.labor_hours.nil? ? 'Unknown' : (sum * 100 / (@business_days*(user.labor_hours))).round(2)  
  		summary[:class] = summary[:percent] == 'Unknown' ? 'unknown' : summary[:percent] < 80 ? 'less' : summary[:percent] > 95 ? 'more' : ''
  	end
  	summary
  end

  def prepare_monthly_summary_csv(monthly_summaries)
    summary_csv = FasterCSV.generate do |csv|
      # header row
      csv << [l(:label_labor_hours), l(:label_member), l(:label_hours), l(:label_percent)]
     
      # data rows
      monthly_summaries.each do |monthly_summary|
        csv << [
                monthly_summary[:labor_hours],
                monthly_summary[:user_name],
                monthly_summary[:sum],
                monthly_summary[:percent]
               ]
      end
    end
  end

end
