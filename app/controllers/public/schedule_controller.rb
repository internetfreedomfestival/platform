class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!

  def index
    @days = @conference.days
    redirect_to public_custom_path
    # respond_to do |format|
    #   format.html
    #   format.xml
    #   format.xcal
    #   format.ics
    #   format.json
    # end
  end

  def style
    respond_to do |format|
      format.css
    end
  end
  
  def custom
    @all_days = @conference.days
    @themes = Event::TYPES
    # Select first day if no button clicked
    if params.keys.include?("day")
      @day_index = params[:day].to_i
      @days = @conference.days.where(id: params[:day])
    else
      @days = @conference.days.where(id: 1)
      @day_index = 1
    end
# @events_by_day_time
    setup_day_ivars

    @days_events = []
    # Get Events for the day
    @events.each do |rooms, events|
      events.each do |event|
        @days_events << event
      end
    end
    # Sort events/day BY start time
    @days_events.sort! {|a,b| a.start_time <=> b.start_time}
    # Sort events/day/start time BY theme
    @themed_days = Hash.new([])
    @days_events.each do |event|
      @themed_days[event.event_type] += [event]
    end

    # arrange days by time
    @events_by_day_time = Hash.new { |k,v| k[v] = [] }
    @days_events.each do |event|
      @events_by_day_time[event.start_time].push(event) unless event.public_type == 'private'
    end
  end

  def custom_show
    @event = Event.find(params[:id])
    e_p = EventPerson.find_by(event_id: @event.id)
    @presenter = Person.find(e_p.person_id)
  end

  def day
    redirect_to public_custom_path
    # @day_index = params[:day].to_i
    # if @day_index < 1 || @day_index > @conference.days.count
    #   return redirect_to public_schedule_index_path, alert: "Failed to find day at index #{@day_index}"
    # end

    # setup_day_ivars

    # if @rooms.empty?
    #   return redirect_to public_schedule_index_path, notice: 'No events are public and scheduled.'
    # end

    # respond_to do |format|
    #   format.html
    #   format.pdf do
    #     @layout = CustomPDF::FullPageLayout.new('A4')
    #     render template: 'schedule/custom_pdf'
    #   end
    # end
  end

  def events
    redirect_to public_custom_path
    # @events = @conference.events_including_subs.is_public.confirmed.scheduled.sort { |a, b|
    #   a.to_sortable <=> b.to_sortable
    # }
    # @events_by_track = @events.group_by(&:track_id)
    # respond_to do |format|
    #   format.html
    #   format.json
    #   format.xls { render file: 'public/schedule/events.xls.erb', content_type: 'application/xls' }
    # end
  end

  def event
    redirect_to public_custom_path
    # @event = @conference.events_including_subs.is_public.confirmed.scheduled.find(params[:id])
    # @concurrent_events = @conference.events_including_subs.is_public.confirmed.scheduled.where(start_time: @event.start_time)
    # respond_to do |format|
    #   format.html
    #   format.ics
    # end
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
    respond_to do |format|
      format.html
      format.json
      format.xls { render file: 'public/schedule/speakers.xls.erb', content_type: 'application/xls' }
    end
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).find(params[:id])
  end

  def qrcode
    @qr = RQRCode::QRCode.new(public_schedule_index_url(format: :xml), size: 8, level: :h)
  end

  private

  def maybe_authenticate_user!
    authenticate_user! unless @conference.schedule_public
  end

  def setup_day_ivars
    @day = @conference.days[@day_index - 1]
    all_rooms = @conference.rooms_including_subs
    @rooms = []
    @events = {}
    @skip_row = {}
    all_rooms.each do |room|
      events = room.events.confirmed.is_public.scheduled_on(@day).order(:start_time).to_a
      # Removed .no_conlicts from the above string to escape "Person availabilities model"
      next if events.empty?
      @events[room] = events
      @skip_row[room] = 0
      @rooms << room
    end
  end
end
