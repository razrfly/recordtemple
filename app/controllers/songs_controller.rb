class SongsController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |controller|
    controller.action_name == "create"
  }

  before_action :set_record, only: [:create, :destroy, :edit, :update]
  before_action :set_song, only: [:destroy, :edit, :update]

  def create
    song = @record.songs.build(audio: params[:file])

    if song.save
      render json: song
    else
      render json: { error: "Failed to process" }, status: 422
    end
  end

  def edit
  end

  def update
    if @song.update_attributes(song_params)
      redirect_to @record, notice: "Song was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @song.destroy

    if @song.destroyed?
      redirect_to [:edit, @record], notice:
        'Song was successfully deleted'
    else
      redirect_to :back, alert: "Song wasn't deleted."
    end
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def set_song
    @song = Song.find(params[:id])
  end

  def song_params
    params.require(:song).permit(:audio, :title)
  end
end
