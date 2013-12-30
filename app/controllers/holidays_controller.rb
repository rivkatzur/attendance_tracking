class HolidaysController < ApplicationController
  unloadable
  before_filter :authorize_global

  def index
  	@holidays = Holiday.order('date')
  end

  def new
  	@holiday = Holiday.new
	respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
      format.js { render :partial => 'update_form' }
    end
  end

  def create
    @holiday = Holiday.create(params[:holiday])
    if @holiday.save
      BusinessTime::Config.holidays << @holiday.date
      respond_to do |format|
        format.html {
          redirect_to(params[:continue] ?  {:action => 'new'} : {:action => 'index'})
        }
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
  	@holiday = Holiday.find(params[:id])
  end

  def update
    @holiday = Holiday.find(params[:id])
    date = @holiday.date
    if @holiday.update_attributes(params[:holiday])
	  BusinessTime::Config.holidays.delete(date)
      BusinessTime::Config.holidays << @holiday.date	
      respond_to do |format|
        format.html {
          redirect_to(params[:continue] ?  {:action => 'edit'} : {:action => 'index'})
        }
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
      end
    end
  end

  def destroy
  	holiday = Holiday.find(params[:id])
  	holiday.delete
  	BusinessTime::Config.holidays.delete(holiday.date)
  	respond_to do |format|
    	format.html { redirect_to(params[:continue] ?  {:action => 'new'} : {:action => 'index'}) }
    end
  end

  def bulk_destroy
  	holidays = Holiday.find(params[:ids])
  	holidays.map(&:delete)
  	BusinessTime::Config.holidays = BusinessTime::Config.holidays - holidays.map(&:date)
  	respond_to do |format|
    	format.html { redirect_to(params[:continue] ?  {:action => 'new'} : {:action => 'index'}) }
    end
  end

  def context_menu
  	@holidays = Holiday.where('id in (?)', params[:ids])
  	@can = {:edit => true,
            :update => true,
            :delete => true
            }
  	render :layout => false
  end
end
