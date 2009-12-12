class LabelsController < ApplicationController
  def index
    @labels = Record.find(:all, :select => 'DISTINCT(label), records.id', :joins => [ :price, :photos ])
  end

end
