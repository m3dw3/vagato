class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /bookings
  def index
    @bookings = Hash.new
    @bookings['BOOKED'] = Array.new
    @bookings['ANSWERED'] = Array.new
    @bookings['CLOSED'] = Array.new

    if current_user.guest?
      Booking.where('guest_id' => current_user.role.id).where.not('state' => 'CART').each do |b|
        if b.state == 'APPROVED' || b.state == 'DENIED'
          @bookings['ANSWERED'].push(b)
        else
          @bookings[b.state].push(b)
        end
      end

    elsif current_user.owner?
      @rooms = Hash.new

      Booking.joins(rooms: [:accommodation]).where('accommodations.owner_id' => current_user.role.id).where.not('bookings.state' => 'CART').uniq.each do |b|
        if b.state == 'APPROVED' || b.state == 'DENIED'
          @bookings['ANSWERED'].push(b)
        else
          @bookings[b.state].push(b)
        end

        b.rooms.each do |r|
          if r.accommodation.owner == current_user.role
            if @rooms[b.id].nil?
              @rooms[b.id] = Array.new
            end

            @rooms[b.id].push(r)
          end
        end
      end
    end
  end

  # GET /bookings/1
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to @booking, notice: 'Booking was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bookings/1
  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: 'Booking was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bookings/1
  def destroy
    @booking.destroy
    redirect_to bookings_url, notice: 'Booking was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def booking_params
      params.require(:booking).permit(:start_date, :end_date, :num_of_nights, :state, :guest_id)
    end
end
