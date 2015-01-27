class SongsController < ApplicationController
  before_action :set_record, only: [:index]

  def index
    @songs = @record.songs
  end

  private
    def set_record
      @record = Record.find(params[:record_id])
    end

end
