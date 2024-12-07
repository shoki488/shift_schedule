class SearchesController < ApplicationController
  def search
    @range = params[:range]
    @word = params[:word]
    @search_type = params[:search]

    if @range == "Shift"
      @shifts = Shift.looks(@search_type, @word)
    else
      @shifts = Shift.none
    end
  end
end
