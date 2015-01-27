class LabelsController < ApplicationController
  before_action :set_label, :only => [:show]

  def index
    @labels = Labels.page(params[:page])
  end

  def show
  end

  private
    def set_label
      @label = Label.find(params[:id])
    end

end
