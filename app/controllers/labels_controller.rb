class LabelsController < ApplicationController
  def index
    @labels = Record.find(:all, :select => 'DISTINCT(label), MIN(records.id) as ID', :joins => [ :price, :photos ], :group => :label)
  end

end
