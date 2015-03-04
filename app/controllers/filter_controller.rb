class FilterController < ApplicationController
  def filter
=begin
    @search = Filter.new(search_params)

    @search.attributes = search_params

    puts params
    s_start_date = params[:start_date]
    puts "start_date: #{s_start_date}"

    @search.start_date = s_start_date
=end

    url = '/rooms?search&'

    params[:filter].keys.each do |key|
      url += "#{key}=#{params[:filter][key]}&"
    end

    puts params
    puts url

    redirect_to url
  end

  def type_cast_from_user(param)
    puts param
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def search_params
    params.require(:filter).permit(:start_date, :end_date, :smart) #, {equipment_ids: []}, {serviice_ids: []})
  end
end