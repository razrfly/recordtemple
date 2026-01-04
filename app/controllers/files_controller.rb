# Serves photo and song files via Active Storage
# Legacy Refile routes maintained for backwards compatibility
class FilesController < ApplicationController
  include ActiveStorage::SetCurrent

  def photo
    @photo = Photo.find(params[:id])

    if (attachment = @photo.active_storage_attachment)
      redirect_to rails_blob_url(attachment, disposition: "inline"), allow_other_host: true
    else
      head :not_found
    end
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end

  def song
    @song = Song.find(params[:id])

    if (attachment = @song.active_storage_attachment)
      redirect_to rails_blob_url(attachment, disposition: "inline"), allow_other_host: true
    else
      head :not_found
    end
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end
end
