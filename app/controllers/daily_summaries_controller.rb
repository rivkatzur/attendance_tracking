class DailySummariesController < ApplicationController
  unloadable
  before_filter :authorize_global
  layout 'base'

  def index
  	@select_type = 'user'
  end

  def report
  	if params && params[:daily_summary]
  	  @users_ids = params[:daily_summary][:users]	
  	  @projects_ids =  params[:daily_summary][:projects]
  	  @all = params[:daily_summary][:all]
  	  retrieve_date_range unless @all == 'true'
  	  @daily_summaries = []

  	  if params[:daily_summary][:select_type] == 'user'
  	  	@select_type = 'user'
		  if @all
			summaries = DailySummary.select('user_id, spent_on, sum(hours) as hours').where('user_id in (?)', @users_ids).group('user_id', 'spent_on').order('user_id', 'spent_on')
		  else
		   	summaries = DailySummary.select('user_id, spent_on, sum(hours) as hours').where('user_id in (?) AND spent_on >= ? AND spent_on <= ?', @users_ids, @from, @to).group('user_id', 'spent_on').order('user_id', 'spent_on')
		  end
		  @daily_summaries << [nil, summaries] if !summaries.blank? && summaries.map(&:hours).sum > 0
	  elsif params[:daily_summary][:select_type] == 'project'
	  	@select_type = 'project'
	  	@projects_ids.each do |project_id|
		  	if @all
		  		summaries = DailySummary.select('user_id, project_id, spent_on, sum(hours) as hours').where('project_id = ? And user_id in (?)', project_id, @users_ids).group('user_id', 'project_id', 'spent_on').order('project_id', 'user_id', 'spent_on')
		  	else
		  		summaries = DailySummary.select('user_id, project_id, spent_on, sum(hours) as hours').where('project_id = ? And user_id in (?) AND spent_on >= ? AND spent_on <= ?', project_id, @users_ids, @from, @to).group('user_id', 'project_id', 'spent_on').order('project_id', 'user_id', 'spent_on')
		  	end		  	
	  		@daily_summaries << [Project.find(project_id), summaries] if !summaries.blank? && summaries.map(&:hours).sum > 0
		end
	  else
		@daily_summaries = []
	  end
	  	
    else
      redirect_to :action => 'index'
      return
    end
    
    respond_to do |format|
      format.html { render :action => 'details', :layout => false if request.xhr? }
      format.csv  { send_data DailySummary.prepare_daily_summary_csv(@daily_summaries), :filename => 'daily_summaries.csv', :type => "text/csv" }
    end
  end



  # Retrieves the date range based on predefined ranges or specific from/to param dates
  # Stolen from the TimelogController
  def retrieve_date_range
  	@all = false
  	if params[:daily_summary][:from].nil? && params[:daily_summary][:to].nil?
	  @free_period = false
	  @from, @to = nil, nil
	  if params[:daily_summary][:period_type] == '1' || (params[:daily_summary][:period_type].nil? && !params[:daily_summary][:period].nil?)
	    case params[:daily_summary][:period].to_s
	    when 'today'
	      @from = @to = Date.today
	    when 'yesterday'
	      @from = @to = Date.yesterday
	    when 'current_week'
	      @from = Date.today.beginning_of_week(:sunday)
	      @to = @from + 6
	    when 'last_week'
	      @from = Date.today - 7 - (Date.today.cwday - 1)%7
	      @to = @from + 6
	    when 'last_2_weeks'
	      @from = Date.today - 14 - (Date.today.cwday - 1)%7
	      @to = @from + 13
	    when '7_days'
	      @from = Date.today - 7
	      @to = Date.today
	    when 'current_month'
	      @from = Date.civil(Date.today.year, Date.today.month, 1)
	      @to = (@from >> 1) - 1
	    when 'last_month'
	      @from = Date.civil(Date.today.year, Date.today.month, 1) << 1
	      @to = (@from >> 1) - 1
	    when '30_days'
	      @from = Date.today - 30
	      @to = Date.today
	    when 'current_year'
	      @from = Date.civil(Date.today.year, 1, 1)
	      @to = Date.civil(Date.today.year, 12, 31)
	    when 'all'
	      @all = true
	    end
	  elsif params[:free_period] || params[:daily_summary][:period_type] == '2' || (params[:daily_summary][:period_type].nil? && (!params[:daily_summary][:date_from].nil? || !params[:daily_summary][:date_to].nil?))
	    begin; @from = params[:daily_summary][:date_from].to_s.to_date unless params[:daily_summary][:date_from].blank?; rescue; end
	    begin; @to = params[:daily_summary][:date_to].to_s.to_date unless params[:daily_summary][:date_to].blank?; rescue; end
	    @free_period = true
	  else
	    # default
	  end

	  @from, @to = @to, @from if @from && @to && @from > @to
	else
  	  @from = params[:daily_summary][:from]
  	  @to = params[:daily_summary][:to]
    end
  end
end
