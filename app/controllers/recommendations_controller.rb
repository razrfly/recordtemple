class RecommendationsController < ApplicationController
  
  before_filter :login_required
  
  def show
    @recommendation = Recommendation.find_by_token(params[:token])
    if @recommendation
      if @recommendation.expiration > Date.today
        @record = Record.find(@recommendation.record_id)
      else
        flash[:notice] = "We're sorry, this shared link expired on #{@recommendation.expiration}."
        redirect_to root_url
      end
    else
      flash[:notice] = "We're sorry, this shared link could not be located."
      redirect_to root_url
    end
    
  end
  
  def new
    @recommendation = Recommendation.new(:record_id => params[:record_id])
  end
  
  def create
    @recommendation = Recommendation.new(params[:recommendation])
    if @recommendation.save
      Notifier.deliver_recommendation(@recommendation, share_url(@recommendation.token))
      flash[:notice] = "Successfully created recommendation."
      redirect_to records_path(@record)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destroy
    flash[:notice] = "Successfully destroyed recommendation."
    redirect_to recommendations_url
  end
end
