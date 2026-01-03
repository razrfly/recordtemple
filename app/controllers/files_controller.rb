class FilesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:photo, :song]

  def photo
    @photo = Photo.find(params[:id])

    if @photo.image_id.present?
      send_data @photo.file_data,
                type: @photo.content_type,
                filename: @photo.filename,
                disposition: "inline"
    else
      head :not_found
    end
  rescue Aws::S3::Errors::NoSuchKey
    head :not_found
  end

  def song
    @song = Song.find(params[:id])

    if @song.audio_id.present?
      send_data @song.file_data,
                type: @song.content_type,
                filename: @song.filename,
                disposition: "inline"
    else
      head :not_found
    end
  rescue Aws::S3::Errors::NoSuchKey
    head :not_found
  end
end
