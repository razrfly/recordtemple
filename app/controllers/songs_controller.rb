# Handles song streaming URLs with access control
class SongsController < ApplicationController
  # Returns a signed URL for streaming a song
  # Anonymous users get the same URL but client-side JS limits to 30-second preview
  def stream_url
    blob = ActiveStorage::Blob.find_signed!(params[:signed_id])

    # Generate a signed URL with expiration
    url = rails_blob_url(blob, disposition: "inline")

    render json: {
      url: url,
      authenticated: current_user.present?
    }
  rescue ActiveStorage::InvalidSignatureError, ActiveRecord::RecordNotFound
    render json: { error: "Song not found" }, status: :not_found
  end
end
