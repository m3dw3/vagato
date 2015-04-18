class FilterController < ApplicationController
  before_action :set_filter, only: [:smartfilter]

  def filter
    url = UrlHelper.build_parameterised_url(params[:filter])

    if url.nil?
      flash[:danger] = 'Valami hiba történt a szűrés közben'
      redirect_to '/rooms'
    else
      redirect_to url
    end
  end

  def smartfilter
    @rooms = Array.new

    if params.has_key? :filter
      @rooms = FilterHelper.prepare_rooms_for_smartfilter(params)

      tstart = Time.now
      if params.has_key?(:cheap) && params.has_key?(:close)
        distances = GeoHelper.calculate_distances_per_room(@rooms)
        @rooms = OptDataHelper.find_cheap_and_close_solution(@rooms, distances, params[:guests])
      elsif params.has_key? :cheap
        @rooms = OptDataHelper.find_cheap_solution(@rooms, params[:guests])
      elsif params.has_key? :close
        distances = GeoHelper.calculate_distances_per_room(@rooms)
        @rooms = OptDataHelper.find_close_solution(@rooms, distances, params[:guests])
      end
      tend = Time.now
      @execution_time = (tend-tstart).round(2)

      unless @rooms.nil?
        @rooms.sort_by! { |r| r.accommodation.name }
        @map_hash = GeoHelper.create_map_hash_from(@rooms)
      end
    end
  end

  def set_filter
    @filter = Filter.new
    @filter.load_params(params)
  end

end
