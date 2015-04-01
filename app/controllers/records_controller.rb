class RecordsController < ApplicationController

  def index
    @records = (params[:user_id].nil? ? Record.all : Record.where(user: User.find(params[:user_id]))).page(params[:page])
  end

  def show
    @record = Record.find(params[:id])
  end

end
