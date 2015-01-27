class PhotosController < ApplicationController
  before_action :set_record, only: [:index]

  def index
    @photos = @record.photos.all(:order => :position)
  end

  def sort
    params[:photo].each_with_index do |id,index|
      Photo.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  private
    def set_record
      @record = Record.find(params[:record_id])
    end

end
