class UserAccountsController < ApplicationController
  def index
    @user_accounts = current_user.user_accounts
  end
  
  def show
    @user_account = UserAccount.find(params[:id])
  end
  
  def new
    @user_account = UserAccount.new
  end
  
  def create
    @user_account = UserAccount.new(params[:user_account])
    if @user_account.save
      flash[:notice] = "Successfully created user account."
      redirect_to @user_account
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user_account = UserAccount.find(params[:id])
  end
  
  def update
    @user_account = UserAccount.find(params[:id])
    if @user_account.update_attributes(params[:user_account])
      flash[:notice] = "Successfully updated user account."
      redirect_to @user_account
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user_account = UserAccount.find(params[:id])
    @user_account.destroy
    flash[:notice] = "Successfully destroyed user account."
    redirect_to user_accounts_url
  end
end
