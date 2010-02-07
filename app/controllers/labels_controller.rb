class LabelsController < ApplicationController
  def index
    @labels = Record.find(:all, 
                          :select => 'DISTINCT(label), MIN(records.id) as ID', 
                          :joins => [ :price, :photos ], 
                          :group => :label).paginate :per_page => 49, :page => params[:page]
  end

end
