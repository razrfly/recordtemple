class PhotosController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |controller|
    controller.action_name == "create"
  }

  before_action :set_record, only: [:create, :destroy]
  before_action :set_photo, only: [:destroy]

  def create
    photo = @record.photos.build(image: params[:file])

    if photo.save
      render json: photo
    else
      render json: { error: "Failed to process" }, status: 422
    end
  end

  def destroy
    @photo.destroy

    if @photo.destroyed?
      redirect_to [:edit, @record],
        notice: "Photo was successfully deleted."
    else
      redirect_to :back, alert: "Photo wasn't deleted."
    end
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def set_photo
    @photo = Photo.find(params[:id])
  end
end
